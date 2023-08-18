local md5 = {
  _VERSION     = "md5.lua 1.1.0",
  _DESCRIPTION = "MD5 computation in Lua (5.1-3, LuaJIT)",
  _URL         = "https://github.com/kikito/md5.lua",
  _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique García Cota + Adam Baldwin + hanzao + Equi 4 Software

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

-- bit lib implementions

local char, byte, format, rep, sub =
  string.char, string.byte, string.format, string.rep, string.sub
local bit_or, bit_and, bit_not, bit_xor, bit_rshift, bit_lshift

local ok, bit = pcall(require, 'bit')
local ok_ffi, ffi = pcall(require, 'ffi')
if ok then
  bit_or, bit_and, bit_not, bit_xor, bit_rshift, bit_lshift = bit.bor, bit.band, bit.bnot, bit.bxor, bit.rshift, bit.lshift
else
  ok, bit = pcall(require, 'bit32')

  if ok then

    bit_not = bit.bnot

    local tobit = function(n)
      return n <= 0x7fffffff and n or -(bit_not(n) + 1)
    end

    local normalize = function(f)
      return function(a,b) return tobit(f(tobit(a), tobit(b))) end
    end

    bit_or, bit_and, bit_xor = normalize(bit.bor), normalize(bit.band), normalize(bit.bxor)
    bit_rshift, bit_lshift = normalize(bit.rshift), normalize(bit.lshift)

  else

    local function tbl2number(tbl)
      local result = 0
      local power = 1
      for i = 1, #tbl do
        result = result + tbl[i] * power
        power = power * 2
      end
      return result
    end

    local function expand(t1, t2)
      local big, small = t1, t2
      if(#big < #small) then
        big, small = small, big
      end
      -- expand small
      for i = #small + 1, #big do
        small[i] = 0
      end
    end

    local to_bits -- needs to be declared before bit_not

    bit_not = function(n)
      local tbl = to_bits(n)
      local size = math.max(#tbl, 32)
      for i = 1, size do
        if(tbl[i] == 1) then
          tbl[i] = 0
        else
          tbl[i] = 1
        end
      end
      return tbl2number(tbl)
    end

    -- defined as local above
    to_bits = function (n)
      if(n < 0) then
        -- negative
        return to_bits(bit_not(math.abs(n)) + 1)
      end
      -- to bits table
      local tbl = {}
      local cnt = 1
      local last
      while n > 0 do
        last      = n % 2
        tbl[cnt]  = last
        n         = (n-last)/2
        cnt       = cnt + 1
      end

      return tbl
    end

    bit_or = function(m, n)
      local tbl_m = to_bits(m)
      local tbl_n = to_bits(n)
      expand(tbl_m, tbl_n)

      local tbl = {}
      for i = 1, #tbl_m do
        if(tbl_m[i]== 0 and tbl_n[i] == 0) then
          tbl[i] = 0
        else
          tbl[i] = 1
        end
      end

      return tbl2number(tbl)
    end

    bit_and = function(m, n)
      local tbl_m = to_bits(m)
      local tbl_n = to_bits(n)
      expand(tbl_m, tbl_n)

      local tbl = {}
      for i = 1, #tbl_m do
        if(tbl_m[i]== 0 or tbl_n[i] == 0) then
          tbl[i] = 0
        else
          tbl[i] = 1
        end
      end

      return tbl2number(tbl)
    end

    bit_xor = function(m, n)
      local tbl_m = to_bits(m)
      local tbl_n = to_bits(n)
      expand(tbl_m, tbl_n)

      local tbl = {}
      for i = 1, #tbl_m do
        if(tbl_m[i] ~= tbl_n[i]) then
          tbl[i] = 1
        else
          tbl[i] = 0
        end
      end

      return tbl2number(tbl)
    end

    bit_rshift = function(n, bits)
      local high_bit = 0
      if(n < 0) then
        -- negative
        n = bit_not(math.abs(n)) + 1
        high_bit = 0x80000000
      end

      local floor = math.floor

      for i=1, bits do
        n = n/2
        n = bit_or(floor(n), high_bit)
      end
      return floor(n)
    end

    bit_lshift = function(n, bits)
      if(n < 0) then
        -- negative
        n = bit_not(math.abs(n)) + 1
      end

      for i=1, bits do
        n = n*2
      end
      return bit_and(n, 0xFFFFFFFF)
    end
  end
end

-- convert little-endian 32-bit int to a 4-char string
local lei2str
-- function is defined this way to allow full jit compilation (removing UCLO instruction in LuaJIT)
if ok_ffi then
  local ct_IntType = ffi.typeof("int[1]")
  lei2str = function(i) return ffi.string(ct_IntType(i), 4) end
else
  lei2str = function (i)
    local f=function (s) return char( bit_and( bit_rshift(i, s), 255)) end
    return f(0)..f(8)..f(16)..f(24)
  end
end



-- convert raw string to big-endian int
local function str2bei(s)
  local v=0
  for i=1, #s do
    v = v * 256 + byte(s, i)
  end
  return v
end

-- convert raw string to little-endian int
local str2lei

if ok_ffi then
  local ct_constcharptr = ffi.typeof("const char*")
  local ct_constintptr = ffi.typeof("const int*")
  str2lei = function(s)
    local int = ct_constcharptr(s)
    return ffi.cast(ct_constintptr, int)[0]
  end
else
  str2lei = function(s)
    local v=0
    for i = #s,1,-1 do
      v = v*256 + byte(s, i)
    end
    return v
    end
end


-- cut up a string in little-endian ints of given size
local function cut_le_str(s)
  return {
    str2lei(sub(s, 1, 4)),
    str2lei(sub(s, 5, 8)),
    str2lei(sub(s, 9, 12)),
    str2lei(sub(s, 13, 16)),
    str2lei(sub(s, 17, 20)),
    str2lei(sub(s, 21, 24)),
    str2lei(sub(s, 25, 28)),
    str2lei(sub(s, 29, 32)),
    str2lei(sub(s, 33, 36)),
    str2lei(sub(s, 37, 40)),
    str2lei(sub(s, 41, 44)),
    str2lei(sub(s, 45, 48)),
    str2lei(sub(s, 49, 52)),
    str2lei(sub(s, 53, 56)),
    str2lei(sub(s, 57, 60)),
    str2lei(sub(s, 61, 64)),
  }
end

-- An MD5 mplementation in Lua, requires bitlib (hacked to use LuaBit from above, ugh)
-- 10/02/2001 jcw@equi4.com

local CONSTS = {
  0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
  0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
  0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
  0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
  0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
  0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
  0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
  0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
  0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
  0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
  0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
  0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
  0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
  0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
  0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
  0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391,
  0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476
}

local f=function (x,y,z) return bit_or(bit_and(x,y),bit_and(-x-1,z)) end
local g=function (x,y,z) return bit_or(bit_and(x,z),bit_and(y,-z-1)) end
local h=function (x,y,z) return bit_xor(x,bit_xor(y,z)) end
local i=function (x,y,z) return bit_xor(y,bit_or(x,-z-1)) end
local z=function (ff,a,b,c,d,x,s,ac)
  a=bit_and(a+ff(b,c,d)+x+ac,0xFFFFFFFF)
  -- be *very* careful that left shift does not cause rounding!
  return bit_or(bit_lshift(bit_and(a,bit_rshift(0xFFFFFFFF,s)),s),bit_rshift(a,32-s))+b
end

local function transform(A,B,C,D,X)
  local a,b,c,d=A,B,C,D
  local t=CONSTS

  a=z(f,a,b,c,d,X[ 0], 7,t[ 1])
  d=z(f,d,a,b,c,X[ 1],12,t[ 2])
  c=z(f,c,d,a,b,X[ 2],17,t[ 3])
  b=z(f,b,c,d,a,X[ 3],22,t[ 4])
  a=z(f,a,b,c,d,X[ 4], 7,t[ 5])
  d=z(f,d,a,b,c,X[ 5],12,t[ 6])
  c=z(f,c,d,a,b,X[ 6],17,t[ 7])
  b=z(f,b,c,d,a,X[ 7],22,t[ 8])
  a=z(f,a,b,c,d,X[ 8], 7,t[ 9])
  d=z(f,d,a,b,c,X[ 9],12,t[10])
  c=z(f,c,d,a,b,X[10],17,t[11])
  b=z(f,b,c,d,a,X[11],22,t[12])
  a=z(f,a,b,c,d,X[12], 7,t[13])
  d=z(f,d,a,b,c,X[13],12,t[14])
  c=z(f,c,d,a,b,X[14],17,t[15])
  b=z(f,b,c,d,a,X[15],22,t[16])

  a=z(g,a,b,c,d,X[ 1], 5,t[17])
  d=z(g,d,a,b,c,X[ 6], 9,t[18])
  c=z(g,c,d,a,b,X[11],14,t[19])
  b=z(g,b,c,d,a,X[ 0],20,t[20])
  a=z(g,a,b,c,d,X[ 5], 5,t[21])
  d=z(g,d,a,b,c,X[10], 9,t[22])
  c=z(g,c,d,a,b,X[15],14,t[23])
  b=z(g,b,c,d,a,X[ 4],20,t[24])
  a=z(g,a,b,c,d,X[ 9], 5,t[25])
  d=z(g,d,a,b,c,X[14], 9,t[26])
  c=z(g,c,d,a,b,X[ 3],14,t[27])
  b=z(g,b,c,d,a,X[ 8],20,t[28])
  a=z(g,a,b,c,d,X[13], 5,t[29])
  d=z(g,d,a,b,c,X[ 2], 9,t[30])
  c=z(g,c,d,a,b,X[ 7],14,t[31])
  b=z(g,b,c,d,a,X[12],20,t[32])

  a=z(h,a,b,c,d,X[ 5], 4,t[33])
  d=z(h,d,a,b,c,X[ 8],11,t[34])
  c=z(h,c,d,a,b,X[11],16,t[35])
  b=z(h,b,c,d,a,X[14],23,t[36])
  a=z(h,a,b,c,d,X[ 1], 4,t[37])
  d=z(h,d,a,b,c,X[ 4],11,t[38])
  c=z(h,c,d,a,b,X[ 7],16,t[39])
  b=z(h,b,c,d,a,X[10],23,t[40])
  a=z(h,a,b,c,d,X[13], 4,t[41])
  d=z(h,d,a,b,c,X[ 0],11,t[42])
  c=z(h,c,d,a,b,X[ 3],16,t[43])
  b=z(h,b,c,d,a,X[ 6],23,t[44])
  a=z(h,a,b,c,d,X[ 9], 4,t[45])
  d=z(h,d,a,b,c,X[12],11,t[46])
  c=z(h,c,d,a,b,X[15],16,t[47])
  b=z(h,b,c,d,a,X[ 2],23,t[48])

  a=z(i,a,b,c,d,X[ 0], 6,t[49])
  d=z(i,d,a,b,c,X[ 7],10,t[50])
  c=z(i,c,d,a,b,X[14],15,t[51])
  b=z(i,b,c,d,a,X[ 5],21,t[52])
  a=z(i,a,b,c,d,X[12], 6,t[53])
  d=z(i,d,a,b,c,X[ 3],10,t[54])
  c=z(i,c,d,a,b,X[10],15,t[55])
  b=z(i,b,c,d,a,X[ 1],21,t[56])
  a=z(i,a,b,c,d,X[ 8], 6,t[57])
  d=z(i,d,a,b,c,X[15],10,t[58])
  c=z(i,c,d,a,b,X[ 6],15,t[59])
  b=z(i,b,c,d,a,X[13],21,t[60])
  a=z(i,a,b,c,d,X[ 4], 6,t[61])
  d=z(i,d,a,b,c,X[11],10,t[62])
  c=z(i,c,d,a,b,X[ 2],15,t[63])
  b=z(i,b,c,d,a,X[ 9],21,t[64])

  return bit_and(A+a,0xFFFFFFFF),bit_and(B+b,0xFFFFFFFF),
         bit_and(C+c,0xFFFFFFFF),bit_and(D+d,0xFFFFFFFF)
end

----------------------------------------------------------------

local function md5_update(self, s)
  self.pos = self.pos + #s
  s = self.buf .. s
  for ii = 1, #s - 63, 64 do
    local X = cut_le_str(sub(s,ii,ii+63))
    assert(#X == 16)
    X[0] = table.remove(X,1) -- zero based!
    self.a,self.b,self.c,self.d = transform(self.a,self.b,self.c,self.d,X)
  end
  self.buf = sub(s, math.floor(#s/64)*64 + 1, #s)
  return self
end

local function md5_finish(self)
  local msgLen = self.pos
  local padLen = 56 - msgLen % 64

  if msgLen % 64 > 56 then padLen = padLen + 64 end

  if padLen == 0 then padLen = 64 end

  local s = char(128) .. rep(char(0),padLen-1) .. lei2str(bit_and(8*msgLen, 0xFFFFFFFF)) .. lei2str(math.floor(msgLen/0x20000000))
  md5_update(self, s)

  assert(self.pos % 64 == 0)
  return lei2str(self.a) .. lei2str(self.b) .. lei2str(self.c) .. lei2str(self.d)
end

----------------------------------------------------------------

function md5.new()
  return { a = CONSTS[65], b = CONSTS[66], c = CONSTS[67], d = CONSTS[68],
           pos = 0,
           buf = '',
           update = md5_update,
           finish = md5_finish }
end

function md5.tohex(s)
  return format("%08x%08x%08x%08x", str2bei(sub(s, 1, 4)), str2bei(sub(s, 5, 8)), str2bei(sub(s, 9, 12)), str2bei(sub(s, 13, 16)))
end

function md5.sum(s)
  return md5.new():update(s):finish()
end

function md5.sumhexa(s)
  return md5.tohex(md5.sum(s))
end

local string = require("string")
local tostring = tostring

local CRC32 = {
    0x00000000, 0x77073096, 0xee0e612c, 0x990951ba, 
    0x076dc419, 0x706af48f, 0xe963a535, 0x9e6495a3, 
    0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988, 
    0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91, 
    0x1db71064, 0x6ab020f2, 0xf3b97148, 0x84be41de, 
    0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7, 
    0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec, 
    0x14015c4f, 0x63066cd9, 0xfa0f3d63, 0x8d080df5, 
    0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172, 
    0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b, 
    0x35b5a8fa, 0x42b2986c, 0xdbbbc9d6, 0xacbcf940, 
    0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59, 
    0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116, 
    0x21b4f4b5, 0x56b3c423, 0xcfba9599, 0xb8bda50f, 
    0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924, 
    0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d, 
    0x76dc4190, 0x01db7106, 0x98d220bc, 0xefd5102a, 
    0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433, 
    0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818, 
    0x7f6a0dbb, 0x086d3d2d, 0x91646c97, 0xe6635c01, 
    0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e, 
    0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457, 
    0x65b0d9c6, 0x12b7e950, 0x8bbeb8ea, 0xfcb9887c, 
    0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65, 
    0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2, 
    0x4adfa541, 0x3dd895d7, 0xa4d1c46d, 0xd3d6f4fb, 
    0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0, 
    0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9, 
    0x5005713c, 0x270241aa, 0xbe0b1010, 0xc90c2086, 
    0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f, 
    0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4, 
    0x59b33d17, 0x2eb40d81, 0xb7bd5c3b, 0xc0ba6cad, 
    0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a, 
    0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683, 
    0xe3630b12, 0x94643b84, 0x0d6d6a3e, 0x7a6a5aa8, 
    0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1, 
    0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe, 
    0xf762575d, 0x806567cb, 0x196c3671, 0x6e6b06e7, 
    0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc, 
    0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5, 
    0xd6d6a3e8, 0xa1d1937e, 0x38d8c2c4, 0x4fdff252, 
    0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b, 
    0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60, 
    0xdf60efc3, 0xa867df55, 0x316e8eef, 0x4669be79, 
    0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236, 
    0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f, 
    0xc5ba3bbe, 0xb2bd0b28, 0x2bb45a92, 0x5cb36a04, 
    0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d, 
    0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a, 
    0x9c0906a9, 0xeb0e363f, 0x72076785, 0x05005713, 
    0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38, 
    0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21, 
    0x86d3d2d4, 0xf1d4e242, 0x68ddb3f8, 0x1fda836e, 
    0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777, 
    0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c, 
    0x8f659eff, 0xf862ae69, 0x616bffd3, 0x166ccf45, 
    0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2, 
    0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db, 
    0xaed16a4a, 0xd9d65adc, 0x40df0b66, 0x37d83bf0, 
    0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9, 
    0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6, 
    0xbad03605, 0xcdd70693, 0x54de5729, 0x23d967bf, 
    0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94, 
    0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d
}

local xor = bit_xor
local lshift = bit_lshift
local rshift = bit_rshift
local band = bit_and

function hash(str)
    str = tostring(str)
    local count = string.len(str)
    local crc = 2 ^ 32 - 1 
    local i = 1

    while count > 0 do
        local byte = string.byte(str, i)
        crc = xor(rshift(crc, 8), CRC32[xor(band(crc, 0xFF), byte) + 1])
        i = i + 1
        count = count - 1
    end
    crc = xor(crc, 0xFFFFFFFF)
    -- dirty hack for bitop return number < 0
    if crc < 0 then crc = crc + 2 ^ 32 end 

    return crc
end

return md5

