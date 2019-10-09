\ $Id: RotateBits.f,v 1.1 2006/07/24 21:22:37 rodoakford Exp $

\ RotateBits.f          Assembler code to rotate bitmaps 90 degrees by Rod Oakford
\                       Only works for 24 bits per pixel with width and height a multiple of 4
\                       but nearly 5 times faster than the FreeImage call.
\                       August 2004

Code RotatePlus90 ( source destination height width -- )
                     \ ebx already contains top stack item, width j+1
pop ecx              \ ecx contains height i+1
xchg edi , 0 [esp]   \ edi contains destination, save edi
xchg esi , 4 [esp]   \ esi contains source, save esi
push edx             \ save edx
push edi             \ save destination on stack
push esi             \ save source on stack
push ebx             \ save width on stack
push ecx             \ save height on stack

                     \ loop over width * height pixels
dec ebx              \ ebx contains width-1, j
@@1:
mov ecx , 0 [esp]    \ ( height i+1 )
@@2:

mov eax , 4 [esp]    \ width
mul ecx              \ * (i+1)
sub eax , ebx        \ - j
dec eax              \ eax = width*(i+1)-j-1

mov esi , 8 [esp]    \ source
add esi , eax        \ esi = source + width*i*3 + [width-j-1]*3
add esi , eax        \ this is equivalent to:
add esi , eax        \ esi = source + 3*[width*(i+1)-j-1]

movsb                \ move 3 bytes for each pixel
movsb
movsb

dec ecx
jnz @@2
dec ebx
jns @@1

                     \ move rotated bits back to original bits
pop ecx              \ height
pop eax              \ width
pop edi              \ original bits
pop esi              \ rotated bits
mul ecx
mov ebx , # 3
mul ebx
mov ecx , eax        \ total number of bytes w*h*3
shr ecx , # 2
rep movsd
mov ecx , eax
and ecx , ebx
rep movsb

                     \ restore edx, edi, esi and move top of stack to ebx
pop edx
pop edi
pop esi
pop ebx
next
End-code


Code RotateMinus90 ( source destination height width -- )
                     \ ebx already contains top stack item, width j+1
pop ecx              \ ecx contains height i+1
xchg edi , 0 [esp]   \ edi contains destination, save edi
xchg esi , 4 [esp]   \ esi contains source, save esi
push edx             \ save edx
push edi             \ save destination on stack
push esi             \ save source on stack
push ebx             \ save width on stack
push ecx             \ save height on stack

                     \ loop over width * height pixels
dec ebx              \ ebx contains width-1, j
@@1:
mov ecx , 0 [esp]    \ ( height i+1 )
@@2:

mov eax , 0 [esp]    \ height
sub eax , ecx        \ -(i+1)
mov edx , 4 [esp]    \ width
mul edx
add eax , ebx        \ eax = width*(height-i-1) + j

mov esi , 8 [esp]    \ source
add esi , eax        \ esi = source + width*(height-i-1)*3 + j*3
add esi , eax        \ this is equivalent to:
add esi , eax        \ esi = source + 3*[width*(height-i-1)+j]

movsb                \ move 3 bytes for each pixel
movsb
movsb

dec ecx
jnz @@2
dec ebx
jns @@1

                     \ move rotated bits back to original bits
pop ecx              \ height
pop eax              \ width
pop edi              \ original bits
pop esi              \ rotated bits
mul ecx
mov ebx , # 3
mul ebx
mov ecx , eax        \ total number of bytes w*h*3
shr ecx , # 2
rep movsd
mov ecx , eax
and ecx , ebx
rep movsb

                     \ restore edx, edi, esi and move top of stack to ebx
pop edx
pop edi
pop esi
pop ebx
next
End-code
