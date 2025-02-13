; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,SSE,SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 | FileCheck %s --check-prefixes=CHECK,SSE,SSE41
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=CHECK,AVX,AVX2,AVX2-SLOW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2,+fast-variable-crosslane-shuffle,+fast-variable-perlane-shuffle | FileCheck %s --check-prefixes=CHECK,AVX,AVX2,AVX2-FAST-ALL
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2,+fast-variable-perlane-shuffle | FileCheck %s --check-prefixes=CHECK,AVX,AVX2,AVX2-FAST-PERLANE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=x86-64-v4 | FileCheck %s --check-prefixes=CHECK,AVX,AVX512

; fold (srl 0, x) -> 0
define <4 x i32> @combine_vec_lshr_zero(<4 x i32> %x) {
; SSE-LABEL: combine_vec_lshr_zero:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_lshr_zero:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = lshr <4 x i32> zeroinitializer, %x
  ret <4 x i32> %1
}

; fold (srl x, c >= size(x)) -> undef
define <4 x i32> @combine_vec_lshr_outofrange0(<4 x i32> %x) {
; CHECK-LABEL: combine_vec_lshr_outofrange0:
; CHECK:       # %bb.0:
; CHECK-NEXT:    retq
  %1 = lshr <4 x i32> %x, <i32 33, i32 33, i32 33, i32 33>
  ret <4 x i32> %1
}

define <4 x i32> @combine_vec_lshr_outofrange1(<4 x i32> %x) {
; CHECK-LABEL: combine_vec_lshr_outofrange1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    retq
  %1 = lshr <4 x i32> %x, <i32 33, i32 34, i32 35, i32 36>
  ret <4 x i32> %1
}

define <4 x i32> @combine_vec_lshr_outofrange2(<4 x i32> %x) {
; CHECK-LABEL: combine_vec_lshr_outofrange2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    retq
  %1 = lshr <4 x i32> %x, <i32 33, i32 34, i32 35, i32 undef>
  ret <4 x i32> %1
}

; fold (srl x, 0) -> x
define <4 x i32> @combine_vec_lshr_by_zero(<4 x i32> %x) {
; CHECK-LABEL: combine_vec_lshr_by_zero:
; CHECK:       # %bb.0:
; CHECK-NEXT:    retq
  %1 = lshr <4 x i32> %x, zeroinitializer
  ret <4 x i32> %1
}

; if (srl x, c) is known to be zero, return 0
define <4 x i32> @combine_vec_lshr_known_zero0(<4 x i32> %x) {
; SSE-LABEL: combine_vec_lshr_known_zero0:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_lshr_known_zero0:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = and <4 x i32> %x, <i32 15, i32 15, i32 15, i32 15>
  %2 = lshr <4 x i32> %1, <i32 4, i32 4, i32 4, i32 4>
  ret <4 x i32> %2
}

define <4 x i32> @combine_vec_lshr_known_zero1(<4 x i32> %x) {
; SSE-LABEL: combine_vec_lshr_known_zero1:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_lshr_known_zero1:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = and <4 x i32> %x, <i32 15, i32 15, i32 15, i32 15>
  %2 = lshr <4 x i32> %1, <i32 8, i32 9, i32 10, i32 11>
  ret <4 x i32> %2
}

; fold (srl (srl x, c1), c2) -> (srl x, (add c1, c2))
define <4 x i32> @combine_vec_lshr_lshr0(<4 x i32> %x) {
; SSE-LABEL: combine_vec_lshr_lshr0:
; SSE:       # %bb.0:
; SSE-NEXT:    psrld $6, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_lshr_lshr0:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsrld $6, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = lshr <4 x i32> %x, <i32 2, i32 2, i32 2, i32 2>
  %2 = lshr <4 x i32> %1, <i32 4, i32 4, i32 4, i32 4>
  ret <4 x i32> %2
}

define <4 x i32> @combine_vec_lshr_lshr1(<4 x i32> %x) {
; SSE2-LABEL: combine_vec_lshr_lshr1:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrld $10, %xmm1
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    psrld $8, %xmm2
; SSE2-NEXT:    punpckhqdq {{.*#+}} xmm2 = xmm2[1],xmm1[1]
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrld $6, %xmm1
; SSE2-NEXT:    psrld $4, %xmm0
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,3],xmm2[0,3]
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_lshr_lshr1:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    psrld $10, %xmm1
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    psrld $6, %xmm2
; SSE41-NEXT:    pblendw {{.*#+}} xmm2 = xmm2[0,1,2,3],xmm1[4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm1
; SSE41-NEXT:    psrld $8, %xmm1
; SSE41-NEXT:    psrld $4, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm1[4,5,6,7]
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1],xmm2[2,3],xmm0[4,5],xmm2[6,7]
; SSE41-NEXT:    retq
;
; AVX-LABEL: combine_vec_lshr_lshr1:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsrlvd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = lshr <4 x i32> %x, <i32 0, i32 1, i32 2, i32 3>
  %2 = lshr <4 x i32> %1, <i32 4, i32 5, i32 6, i32 7>
  ret <4 x i32> %2
}

; fold (srl (srl x, c1), c2) -> 0
define <4 x i32> @combine_vec_lshr_lshr_zero0(<4 x i32> %x) {
; SSE-LABEL: combine_vec_lshr_lshr_zero0:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_lshr_lshr_zero0:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = lshr <4 x i32> %x, <i32 16, i32 16, i32 16, i32 16>
  %2 = lshr <4 x i32> %1, <i32 20, i32 20, i32 20, i32 20>
  ret <4 x i32> %2
}

define <4 x i32> @combine_vec_lshr_lshr_zero1(<4 x i32> %x) {
; SSE-LABEL: combine_vec_lshr_lshr_zero1:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_lshr_lshr_zero1:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = lshr <4 x i32> %x, <i32 17, i32 18, i32 19, i32 20>
  %2 = lshr <4 x i32> %1, <i32 25, i32 26, i32 27, i32 28>
  ret <4 x i32> %2
}

; fold (srl (trunc (srl x, c1)), c2) -> (trunc (srl x, (add c1, c2)))
define <4 x i32> @combine_vec_lshr_trunc_lshr0(<4 x i64> %x) {
; SSE2-LABEL: combine_vec_lshr_trunc_lshr0:
; SSE2:       # %bb.0:
; SSE2-NEXT:    psrlq $48, %xmm1
; SSE2-NEXT:    psrlq $48, %xmm0
; SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,2],xmm1[0,2]
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_lshr_trunc_lshr0:
; SSE41:       # %bb.0:
; SSE41-NEXT:    psrlq $48, %xmm1
; SSE41-NEXT:    psrlq $48, %xmm0
; SSE41-NEXT:    packusdw %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX2-SLOW-LABEL: combine_vec_lshr_trunc_lshr0:
; AVX2-SLOW:       # %bb.0:
; AVX2-SLOW-NEXT:    vpsrlq $48, %ymm0, %ymm0
; AVX2-SLOW-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-SLOW-NEXT:    vpackusdw %xmm1, %xmm0, %xmm0
; AVX2-SLOW-NEXT:    vzeroupper
; AVX2-SLOW-NEXT:    retq
;
; AVX2-FAST-ALL-LABEL: combine_vec_lshr_trunc_lshr0:
; AVX2-FAST-ALL:       # %bb.0:
; AVX2-FAST-ALL-NEXT:    vpsrlq $48, %ymm0, %ymm0
; AVX2-FAST-ALL-NEXT:    vpmovsxbd {{.*#+}} ymm1 = [0,2,4,6,0,0,0,0]
; AVX2-FAST-ALL-NEXT:    vpermd %ymm0, %ymm1, %ymm0
; AVX2-FAST-ALL-NEXT:    # kill: def $xmm0 killed $xmm0 killed $ymm0
; AVX2-FAST-ALL-NEXT:    vzeroupper
; AVX2-FAST-ALL-NEXT:    retq
;
; AVX2-FAST-PERLANE-LABEL: combine_vec_lshr_trunc_lshr0:
; AVX2-FAST-PERLANE:       # %bb.0:
; AVX2-FAST-PERLANE-NEXT:    vpsrlq $48, %ymm0, %ymm0
; AVX2-FAST-PERLANE-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-FAST-PERLANE-NEXT:    vpackusdw %xmm1, %xmm0, %xmm0
; AVX2-FAST-PERLANE-NEXT:    vzeroupper
; AVX2-FAST-PERLANE-NEXT:    retq
;
; AVX512-LABEL: combine_vec_lshr_trunc_lshr0:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpsrlq $48, %ymm0, %ymm0
; AVX512-NEXT:    vpmovqd %ymm0, %xmm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = lshr <4 x i64> %x, <i64 32, i64 32, i64 32, i64 32>
  %2 = trunc <4 x i64> %1 to <4 x i32>
  %3 = lshr <4 x i32> %2, <i32 16, i32 16, i32 16, i32 16>
  ret <4 x i32> %3
}

define <4 x i32> @combine_vec_lshr_trunc_lshr1(<4 x i64> %x) {
; SSE2-LABEL: combine_vec_lshr_trunc_lshr1:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa %xmm1, %xmm2
; SSE2-NEXT:    psrlq $34, %xmm2
; SSE2-NEXT:    psrlq $35, %xmm1
; SSE2-NEXT:    movsd {{.*#+}} xmm1 = xmm2[0],xmm1[1]
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    psrlq $32, %xmm2
; SSE2-NEXT:    psrlq $33, %xmm0
; SSE2-NEXT:    movsd {{.*#+}} xmm0 = xmm2[0],xmm0[1]
; SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,2],xmm1[0,2]
; SSE2-NEXT:    movaps %xmm0, %xmm1
; SSE2-NEXT:    psrld $19, %xmm1
; SSE2-NEXT:    movaps %xmm0, %xmm3
; SSE2-NEXT:    psrld $18, %xmm3
; SSE2-NEXT:    punpckhqdq {{.*#+}} xmm3 = xmm3[1],xmm1[1]
; SSE2-NEXT:    psrld $17, %xmm0
; SSE2-NEXT:    psrld $16, %xmm2
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm0[0]
; SSE2-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,3],xmm3[0,3]
; SSE2-NEXT:    movaps %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_lshr_trunc_lshr1:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movdqa %xmm1, %xmm2
; SSE41-NEXT:    psrlq $35, %xmm2
; SSE41-NEXT:    psrlq $34, %xmm1
; SSE41-NEXT:    pblendw {{.*#+}} xmm1 = xmm1[0,1,2,3],xmm2[4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm2
; SSE41-NEXT:    psrlq $33, %xmm2
; SSE41-NEXT:    psrlq $32, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm2 = xmm0[0,1,2,3],xmm2[4,5,6,7]
; SSE41-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,2],xmm1[0,2]
; SSE41-NEXT:    movaps %xmm2, %xmm1
; SSE41-NEXT:    psrld $19, %xmm1
; SSE41-NEXT:    movaps %xmm2, %xmm3
; SSE41-NEXT:    psrld $17, %xmm3
; SSE41-NEXT:    pblendw {{.*#+}} xmm3 = xmm3[0,1,2,3],xmm1[4,5,6,7]
; SSE41-NEXT:    psrld $18, %xmm2
; SSE41-NEXT:    psrld $16, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm2[4,5,6,7]
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1],xmm3[2,3],xmm0[4,5],xmm3[6,7]
; SSE41-NEXT:    retq
;
; AVX2-SLOW-LABEL: combine_vec_lshr_trunc_lshr1:
; AVX2-SLOW:       # %bb.0:
; AVX2-SLOW-NEXT:    vpsrlvq {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %ymm0, %ymm0
; AVX2-SLOW-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-SLOW-NEXT:    vshufps {{.*#+}} xmm0 = xmm0[0,2],xmm1[0,2]
; AVX2-SLOW-NEXT:    vpsrlvd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; AVX2-SLOW-NEXT:    vzeroupper
; AVX2-SLOW-NEXT:    retq
;
; AVX2-FAST-ALL-LABEL: combine_vec_lshr_trunc_lshr1:
; AVX2-FAST-ALL:       # %bb.0:
; AVX2-FAST-ALL-NEXT:    vpsrlvq {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %ymm0, %ymm0
; AVX2-FAST-ALL-NEXT:    vpmovsxbd {{.*#+}} ymm1 = [0,2,4,6,0,0,0,0]
; AVX2-FAST-ALL-NEXT:    vpermd %ymm0, %ymm1, %ymm0
; AVX2-FAST-ALL-NEXT:    vpsrlvd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; AVX2-FAST-ALL-NEXT:    vzeroupper
; AVX2-FAST-ALL-NEXT:    retq
;
; AVX2-FAST-PERLANE-LABEL: combine_vec_lshr_trunc_lshr1:
; AVX2-FAST-PERLANE:       # %bb.0:
; AVX2-FAST-PERLANE-NEXT:    vpsrlvq {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %ymm0, %ymm0
; AVX2-FAST-PERLANE-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-FAST-PERLANE-NEXT:    vshufps {{.*#+}} xmm0 = xmm0[0,2],xmm1[0,2]
; AVX2-FAST-PERLANE-NEXT:    vpsrlvd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; AVX2-FAST-PERLANE-NEXT:    vzeroupper
; AVX2-FAST-PERLANE-NEXT:    retq
;
; AVX512-LABEL: combine_vec_lshr_trunc_lshr1:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpsrlvq {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %ymm0, %ymm0
; AVX512-NEXT:    vpmovqd %ymm0, %xmm0
; AVX512-NEXT:    vpsrlvd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = lshr <4 x i64> %x, <i64 32, i64 33, i64 34, i64 35>
  %2 = trunc <4 x i64> %1 to <4 x i32>
  %3 = lshr <4 x i32> %2, <i32 16, i32 17, i32 18, i32 19>
  ret <4 x i32> %3
}

; fold (srl (trunc (srl x, c1)), c2) -> 0
define <4 x i32> @combine_vec_lshr_trunc_lshr_zero0(<4 x i64> %x) {
; SSE-LABEL: combine_vec_lshr_trunc_lshr_zero0:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_lshr_trunc_lshr_zero0:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = lshr <4 x i64> %x, <i64 48, i64 48, i64 48, i64 48>
  %2 = trunc <4 x i64> %1 to <4 x i32>
  %3 = lshr <4 x i32> %2, <i32 24, i32 24, i32 24, i32 24>
  ret <4 x i32> %3
}

define <4 x i32> @combine_vec_lshr_trunc_lshr_zero1(<4 x i64> %x) {
; SSE-LABEL: combine_vec_lshr_trunc_lshr_zero1:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_lshr_trunc_lshr_zero1:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = lshr <4 x i64> %x, <i64 48, i64 49, i64 50, i64 51>
  %2 = trunc <4 x i64> %1 to <4 x i32>
  %3 = lshr <4 x i32> %2, <i32 24, i32 25, i32 26, i32 27>
  ret <4 x i32> %3
}

; fold (srl (shl x, c), c) -> (and x, cst2)
define <4 x i32> @combine_vec_lshr_shl_mask0(<4 x i32> %x) {
; SSE-LABEL: combine_vec_lshr_shl_mask0:
; SSE:       # %bb.0:
; SSE-NEXT:    andps {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX2-LABEL: combine_vec_lshr_shl_mask0:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vbroadcastss {{.*#+}} xmm1 = [1073741823,1073741823,1073741823,1073741823]
; AVX2-NEXT:    vandps %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: combine_vec_lshr_shl_mask0:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vandps {{\.?LCPI[0-9]+_[0-9]+}}(%rip){1to4}, %xmm0, %xmm0
; AVX512-NEXT:    retq
  %1 =  shl <4 x i32> %x, <i32 2, i32 2, i32 2, i32 2>
  %2 = lshr <4 x i32> %1, <i32 2, i32 2, i32 2, i32 2>
  ret <4 x i32> %2
}

define <4 x i32> @combine_vec_lshr_shl_mask1(<4 x i32> %x) {
; SSE-LABEL: combine_vec_lshr_shl_mask1:
; SSE:       # %bb.0:
; SSE-NEXT:    andps {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_lshr_shl_mask1:
; AVX:       # %bb.0:
; AVX-NEXT:    vandps {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 =  shl <4 x i32> %x, <i32 2, i32 3, i32 4, i32 5>
  %2 = lshr <4 x i32> %1, <i32 2, i32 3, i32 4, i32 5>
  ret <4 x i32> %2
}

; fold (srl (sra X, Y), 31) -> (srl X, 31)
define <4 x i32> @combine_vec_lshr_ashr_sign(<4 x i32> %x, <4 x i32> %y) {
; SSE-LABEL: combine_vec_lshr_ashr_sign:
; SSE:       # %bb.0:
; SSE-NEXT:    psrld $31, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_lshr_ashr_sign:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsrld $31, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = ashr <4 x i32> %x, %y
  %2 = lshr <4 x i32> %1, <i32 31, i32 31, i32 31, i32 31>
  ret <4 x i32> %2
}

; fold (srl (ctlz x), "5") -> x  iff x has one bit set (the low bit).
define <4 x i32> @combine_vec_lshr_lzcnt_bit0(<4 x i32> %x) {
; SSE-LABEL: combine_vec_lshr_lzcnt_bit0:
; SSE:       # %bb.0:
; SSE-NEXT:    psrld $4, %xmm0
; SSE-NEXT:    pandn {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX2-LABEL: combine_vec_lshr_lzcnt_bit0:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpsrld $4, %xmm0, %xmm0
; AVX2-NEXT:    vpbroadcastd {{.*#+}} xmm1 = [1,1,1,1]
; AVX2-NEXT:    vpandn %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: combine_vec_lshr_lzcnt_bit0:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpsrld $4, %xmm0, %xmm0
; AVX512-NEXT:    vpandnd {{\.?LCPI[0-9]+_[0-9]+}}(%rip){1to4}, %xmm0, %xmm0
; AVX512-NEXT:    retq
  %1 = and <4 x i32> %x, <i32 16, i32 16, i32 16, i32 16>
  %2 = call <4 x i32> @llvm.ctlz.v4i32(<4 x i32> %1, i1 0)
  %3 = lshr <4 x i32> %2, <i32 5, i32 5, i32 5, i32 5>
  ret <4 x i32> %3
}

define <4 x i32> @combine_vec_lshr_lzcnt_bit1(<4 x i32> %x) {
; SSE2-LABEL: combine_vec_lshr_lzcnt_bit1:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pand {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrld $1, %xmm1
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrld $2, %xmm1
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrld $4, %xmm1
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrld $8, %xmm1
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrld $16, %xmm1
; SSE2-NEXT:    por %xmm1, %xmm0
; SSE2-NEXT:    pcmpeqd %xmm1, %xmm1
; SSE2-NEXT:    pxor %xmm1, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrlw $1, %xmm1
; SSE2-NEXT:    pand {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm1
; SSE2-NEXT:    psubb %xmm1, %xmm0
; SSE2-NEXT:    movdqa {{.*#+}} xmm1 = [51,51,51,51,51,51,51,51,51,51,51,51,51,51,51,51]
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    pand %xmm1, %xmm2
; SSE2-NEXT:    psrlw $2, %xmm0
; SSE2-NEXT:    pand %xmm1, %xmm0
; SSE2-NEXT:    paddb %xmm2, %xmm0
; SSE2-NEXT:    movdqa %xmm0, %xmm1
; SSE2-NEXT:    psrlw $4, %xmm1
; SSE2-NEXT:    paddb %xmm1, %xmm0
; SSE2-NEXT:    pand {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; SSE2-NEXT:    pxor %xmm1, %xmm1
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    punpckhdq {{.*#+}} xmm2 = xmm2[2],xmm1[2],xmm2[3],xmm1[3]
; SSE2-NEXT:    psadbw %xmm1, %xmm2
; SSE2-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm1[0],xmm0[1],xmm1[1]
; SSE2-NEXT:    psadbw %xmm1, %xmm0
; SSE2-NEXT:    packuswb %xmm2, %xmm0
; SSE2-NEXT:    psrld $5, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_lshr_lzcnt_bit1:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pand {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; SSE41-NEXT:    movq {{.*#+}} xmm1 = [4,3,2,2,1,1,1,1,0,0,0,0,0,0,0,0]
; SSE41-NEXT:    movdqa %xmm1, %xmm2
; SSE41-NEXT:    pshufb %xmm0, %xmm2
; SSE41-NEXT:    psrlw $4, %xmm0
; SSE41-NEXT:    pxor %xmm3, %xmm3
; SSE41-NEXT:    pshufb %xmm0, %xmm1
; SSE41-NEXT:    pcmpeqb %xmm3, %xmm0
; SSE41-NEXT:    pand %xmm2, %xmm0
; SSE41-NEXT:    paddb %xmm1, %xmm0
; SSE41-NEXT:    pmovzxbw {{.*#+}} xmm1 = [255,255,255,255,255,255,255,255]
; SSE41-NEXT:    pand %xmm0, %xmm1
; SSE41-NEXT:    psrlw $8, %xmm0
; SSE41-NEXT:    paddw %xmm1, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm3 = xmm0[0],xmm3[1],xmm0[2],xmm3[3],xmm0[4],xmm3[5],xmm0[6],xmm3[7]
; SSE41-NEXT:    psrld $16, %xmm0
; SSE41-NEXT:    paddd %xmm3, %xmm0
; SSE41-NEXT:    psrld $5, %xmm0
; SSE41-NEXT:    retq
;
; AVX2-LABEL: combine_vec_lshr_lzcnt_bit1:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpand {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; AVX2-NEXT:    vmovq {{.*#+}} xmm1 = [4,3,2,2,1,1,1,1,0,0,0,0,0,0,0,0]
; AVX2-NEXT:    vpshufb %xmm0, %xmm1, %xmm2
; AVX2-NEXT:    vpsrlw $4, %xmm0, %xmm0
; AVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpcmpeqb %xmm3, %xmm0, %xmm4
; AVX2-NEXT:    vpand %xmm4, %xmm2, %xmm2
; AVX2-NEXT:    vpshufb %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    vpaddb %xmm0, %xmm2, %xmm0
; AVX2-NEXT:    vpand {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm1
; AVX2-NEXT:    vpsrlw $8, %xmm0, %xmm0
; AVX2-NEXT:    vpaddw %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpblendw {{.*#+}} xmm1 = xmm0[0],xmm3[1],xmm0[2],xmm3[3],xmm0[4],xmm3[5],xmm0[6],xmm3[7]
; AVX2-NEXT:    vpsrld $16, %xmm0, %xmm0
; AVX2-NEXT:    vpaddd %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpsrld $5, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: combine_vec_lshr_lzcnt_bit1:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpand {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0, %xmm0
; AVX512-NEXT:    vplzcntd %xmm0, %xmm0
; AVX512-NEXT:    vpsrld $5, %xmm0, %xmm0
; AVX512-NEXT:    retq
  %1 = and <4 x i32> %x, <i32 4, i32 32, i32 64, i32 128>
  %2 = call <4 x i32> @llvm.ctlz.v4i32(<4 x i32> %1, i1 0)
  %3 = lshr <4 x i32> %2, <i32 5, i32 5, i32 5, i32 5>
  ret <4 x i32> %3
}
declare <4 x i32> @llvm.ctlz.v4i32(<4 x i32>, i1)

; fold (srl x, (trunc (and y, c))) -> (srl x, (and (trunc y), (trunc c))).
define <4 x i32> @combine_vec_lshr_trunc_and(<4 x i32> %x, <4 x i64> %y) {
; SSE2-LABEL: combine_vec_lshr_trunc_and:
; SSE2:       # %bb.0:
; SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,2],xmm2[0,2]
; SSE2-NEXT:    andps {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm1
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm1[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    psrld %xmm2, %xmm3
; SSE2-NEXT:    pshuflw {{.*#+}} xmm4 = xmm1[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm2
; SSE2-NEXT:    psrld %xmm4, %xmm2
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm3[0]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm1[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm4
; SSE2-NEXT:    psrld %xmm3, %xmm4
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    psrld %xmm1, %xmm0
; SSE2-NEXT:    punpckhqdq {{.*#+}} xmm0 = xmm0[1],xmm4[1]
; SSE2-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,3],xmm0[0,3]
; SSE2-NEXT:    movaps %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_lshr_trunc_and:
; SSE41:       # %bb.0:
; SSE41-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,2],xmm2[0,2]
; SSE41-NEXT:    andps {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm1
; SSE41-NEXT:    pshuflw {{.*#+}} xmm2 = xmm1[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm3
; SSE41-NEXT:    psrld %xmm2, %xmm3
; SSE41-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,2,3]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm4 = xmm2[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm5
; SSE41-NEXT:    psrld %xmm4, %xmm5
; SSE41-NEXT:    pblendw {{.*#+}} xmm5 = xmm3[0,1,2,3],xmm5[4,5,6,7]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm3
; SSE41-NEXT:    psrld %xmm1, %xmm3
; SSE41-NEXT:    pshuflw {{.*#+}} xmm1 = xmm2[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    psrld %xmm1, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm3[0,1,2,3],xmm0[4,5,6,7]
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1],xmm5[2,3],xmm0[4,5],xmm5[6,7]
; SSE41-NEXT:    retq
;
; AVX2-SLOW-LABEL: combine_vec_lshr_trunc_and:
; AVX2-SLOW:       # %bb.0:
; AVX2-SLOW-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX2-SLOW-NEXT:    vshufps {{.*#+}} xmm1 = xmm1[0,2],xmm2[0,2]
; AVX2-SLOW-NEXT:    vandps {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm1, %xmm1
; AVX2-SLOW-NEXT:    vpsrlvd %xmm1, %xmm0, %xmm0
; AVX2-SLOW-NEXT:    vzeroupper
; AVX2-SLOW-NEXT:    retq
;
; AVX2-FAST-ALL-LABEL: combine_vec_lshr_trunc_and:
; AVX2-FAST-ALL:       # %bb.0:
; AVX2-FAST-ALL-NEXT:    vpmovsxbd {{.*#+}} ymm2 = [0,2,4,6,0,0,0,0]
; AVX2-FAST-ALL-NEXT:    vpermd %ymm1, %ymm2, %ymm1
; AVX2-FAST-ALL-NEXT:    vpand {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm1, %xmm1
; AVX2-FAST-ALL-NEXT:    vpsrlvd %xmm1, %xmm0, %xmm0
; AVX2-FAST-ALL-NEXT:    vzeroupper
; AVX2-FAST-ALL-NEXT:    retq
;
; AVX2-FAST-PERLANE-LABEL: combine_vec_lshr_trunc_and:
; AVX2-FAST-PERLANE:       # %bb.0:
; AVX2-FAST-PERLANE-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX2-FAST-PERLANE-NEXT:    vshufps {{.*#+}} xmm1 = xmm1[0,2],xmm2[0,2]
; AVX2-FAST-PERLANE-NEXT:    vandps {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm1, %xmm1
; AVX2-FAST-PERLANE-NEXT:    vpsrlvd %xmm1, %xmm0, %xmm0
; AVX2-FAST-PERLANE-NEXT:    vzeroupper
; AVX2-FAST-PERLANE-NEXT:    retq
;
; AVX512-LABEL: combine_vec_lshr_trunc_and:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpmovqd %ymm1, %xmm1
; AVX512-NEXT:    vpand {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm1, %xmm1
; AVX512-NEXT:    vpsrlvd %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = and <4 x i64> %y, <i64 15, i64 255, i64 4095, i64 65535>
  %2 = trunc <4 x i64> %1 to <4 x i32>
  %3 = lshr <4 x i32> %x, %2
  ret <4 x i32> %3
}

define <4 x i32> @combine_vec_lshr_clamped1(<4 x i32> %sh, <4 x i32> %amt) {
; SSE2-LABEL: combine_vec_lshr_clamped1:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm2
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm1[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm4
; SSE2-NEXT:    psrld %xmm3, %xmm4
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm1[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    psrld %xmm3, %xmm5
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm5 = xmm5[0],xmm4[0]
; SSE2-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm1[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm4
; SSE2-NEXT:    psrld %xmm3, %xmm4
; SSE2-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    psrld %xmm1, %xmm0
; SSE2-NEXT:    punpckhqdq {{.*#+}} xmm0 = xmm0[1],xmm4[1]
; SSE2-NEXT:    shufps {{.*#+}} xmm5 = xmm5[0,3],xmm0[0,3]
; SSE2-NEXT:    pandn %xmm5, %xmm2
; SSE2-NEXT:    movdqa %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_lshr_clamped1:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pmovsxbd {{.*#+}} xmm2 = [31,31,31,31]
; SSE41-NEXT:    pminud %xmm1, %xmm2
; SSE41-NEXT:    pcmpeqd %xmm1, %xmm2
; SSE41-NEXT:    pshuflw {{.*#+}} xmm3 = xmm1[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm4
; SSE41-NEXT:    psrld %xmm3, %xmm4
; SSE41-NEXT:    pshufd {{.*#+}} xmm3 = xmm1[2,3,2,3]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm5 = xmm3[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm6
; SSE41-NEXT:    psrld %xmm5, %xmm6
; SSE41-NEXT:    pblendw {{.*#+}} xmm6 = xmm4[0,1,2,3],xmm6[4,5,6,7]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm4
; SSE41-NEXT:    psrld %xmm1, %xmm4
; SSE41-NEXT:    pshuflw {{.*#+}} xmm1 = xmm3[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    psrld %xmm1, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm4[0,1,2,3],xmm0[4,5,6,7]
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1],xmm6[2,3],xmm0[4,5],xmm6[6,7]
; SSE41-NEXT:    pand %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: combine_vec_lshr_clamped1:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsrlvd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %cmp.i = icmp ult <4 x i32> %amt, <i32 32, i32 32, i32 32, i32 32>
  %shr = lshr <4 x i32> %sh, %amt
  %1 = select <4 x i1> %cmp.i, <4 x i32> %shr, <4 x i32> zeroinitializer
  ret <4 x i32> %1
}

define <4 x i32> @combine_vec_lshr_clamped2(<4 x i32> %sh, <4 x i32> %amt) {
; SSE2-LABEL: combine_vec_lshr_clamped2:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[2,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm0[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    psrld %xmm3, %xmm4
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    psrld %xmm0, %xmm3
; SSE2-NEXT:    punpckhqdq {{.*#+}} xmm3 = xmm3[1],xmm4[1]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm1[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    psrld %xmm0, %xmm4
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm1[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    psrld %xmm0, %xmm2
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm4[0]
; SSE2-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,3],xmm3[0,3]
; SSE2-NEXT:    movaps %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_lshr_clamped2:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pmovsxbd {{.*#+}} xmm2 = [31,31,31,31]
; SSE41-NEXT:    pminud %xmm1, %xmm2
; SSE41-NEXT:    pcmpeqd %xmm1, %xmm2
; SSE41-NEXT:    pand %xmm2, %xmm0
; SSE41-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,2,3]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm3 = xmm2[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm4
; SSE41-NEXT:    psrld %xmm3, %xmm4
; SSE41-NEXT:    pshuflw {{.*#+}} xmm3 = xmm1[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm5
; SSE41-NEXT:    psrld %xmm3, %xmm5
; SSE41-NEXT:    pblendw {{.*#+}} xmm5 = xmm5[0,1,2,3],xmm4[4,5,6,7]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm3
; SSE41-NEXT:    psrld %xmm2, %xmm3
; SSE41-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    psrld %xmm1, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm3[4,5,6,7]
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1],xmm5[2,3],xmm0[4,5],xmm5[6,7]
; SSE41-NEXT:    retq
;
; AVX-LABEL: combine_vec_lshr_clamped2:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsrlvd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %cmp.i = icmp ult <4 x i32> %amt, <i32 32, i32 32, i32 32, i32 32>
  %1 = select <4 x i1> %cmp.i, <4 x i32> %sh, <4 x i32> zeroinitializer
  %shr = lshr <4 x i32> %1, %amt
  ret <4 x i32> %shr
}

define <4 x i32> @combine_vec_lshr_commuted_clamped(<4 x i32> %sh, <4 x i32> %amt) {
; SSE2-LABEL: combine_vec_lshr_commuted_clamped:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm2 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    pxor %xmm1, %xmm2
; SSE2-NEXT:    pcmpgtd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm2
; SSE2-NEXT:    pandn %xmm0, %xmm2
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[2,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm0[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    psrld %xmm3, %xmm4
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm2, %xmm3
; SSE2-NEXT:    psrld %xmm0, %xmm3
; SSE2-NEXT:    punpckhqdq {{.*#+}} xmm3 = xmm3[1],xmm4[1]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm1[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    psrld %xmm0, %xmm4
; SSE2-NEXT:    pshuflw {{.*#+}} xmm0 = xmm1[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    psrld %xmm0, %xmm2
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm4[0]
; SSE2-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,3],xmm3[0,3]
; SSE2-NEXT:    movaps %xmm2, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_lshr_commuted_clamped:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pmovsxbd {{.*#+}} xmm2 = [31,31,31,31]
; SSE41-NEXT:    pminud %xmm1, %xmm2
; SSE41-NEXT:    pcmpeqd %xmm1, %xmm2
; SSE41-NEXT:    pand %xmm2, %xmm0
; SSE41-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,2,3]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm3 = xmm2[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm4
; SSE41-NEXT:    psrld %xmm3, %xmm4
; SSE41-NEXT:    pshuflw {{.*#+}} xmm3 = xmm1[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm5
; SSE41-NEXT:    psrld %xmm3, %xmm5
; SSE41-NEXT:    pblendw {{.*#+}} xmm5 = xmm5[0,1,2,3],xmm4[4,5,6,7]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm3
; SSE41-NEXT:    psrld %xmm2, %xmm3
; SSE41-NEXT:    pshuflw {{.*#+}} xmm1 = xmm1[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    psrld %xmm1, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1,2,3],xmm3[4,5,6,7]
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1],xmm5[2,3],xmm0[4,5],xmm5[6,7]
; SSE41-NEXT:    retq
;
; AVX2-LABEL: combine_vec_lshr_commuted_clamped:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpbroadcastd {{.*#+}} xmm2 = [31,31,31,31]
; AVX2-NEXT:    vpminud %xmm2, %xmm1, %xmm2
; AVX2-NEXT:    vpcmpeqd %xmm2, %xmm1, %xmm2
; AVX2-NEXT:    vpand %xmm0, %xmm2, %xmm0
; AVX2-NEXT:    vpsrlvd %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: combine_vec_lshr_commuted_clamped:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpsrlvd %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    retq
  %cmp.i = icmp uge <4 x i32> %amt, <i32 32, i32 32, i32 32, i32 32>
  %1 = select <4 x i1> %cmp.i, <4 x i32> zeroinitializer, <4 x i32> %sh
  %shr = lshr <4 x i32> %1, %amt
  ret <4 x i32> %shr
}

define <4 x i32> @combine_vec_lshr_commuted_clamped1(<4 x i32> %sh, <4 x i32> %amt) {
; SSE2-LABEL: combine_vec_lshr_commuted_clamped1:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm1[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm3
; SSE2-NEXT:    psrld %xmm2, %xmm3
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm1[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm4
; SSE2-NEXT:    psrld %xmm2, %xmm4
; SSE2-NEXT:    punpcklqdq {{.*#+}} xmm4 = xmm4[0],xmm3[0]
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,2,3]
; SSE2-NEXT:    pshuflw {{.*#+}} xmm3 = xmm2[2,3,3,3,4,5,6,7]
; SSE2-NEXT:    movdqa %xmm0, %xmm5
; SSE2-NEXT:    psrld %xmm3, %xmm5
; SSE2-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[0,1,1,1,4,5,6,7]
; SSE2-NEXT:    psrld %xmm2, %xmm0
; SSE2-NEXT:    punpckhqdq {{.*#+}} xmm0 = xmm0[1],xmm5[1]
; SSE2-NEXT:    shufps {{.*#+}} xmm4 = xmm4[0,3],xmm0[0,3]
; SSE2-NEXT:    pxor {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm1
; SSE2-NEXT:    pcmpgtd {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm1
; SSE2-NEXT:    pandn %xmm4, %xmm1
; SSE2-NEXT:    movdqa %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_vec_lshr_commuted_clamped1:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pshuflw {{.*#+}} xmm2 = xmm1[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm3
; SSE41-NEXT:    psrld %xmm2, %xmm3
; SSE41-NEXT:    pshufd {{.*#+}} xmm2 = xmm1[2,3,2,3]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm4 = xmm2[2,3,3,3,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm5
; SSE41-NEXT:    psrld %xmm4, %xmm5
; SSE41-NEXT:    pblendw {{.*#+}} xmm5 = xmm3[0,1,2,3],xmm5[4,5,6,7]
; SSE41-NEXT:    pshuflw {{.*#+}} xmm3 = xmm1[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    movdqa %xmm0, %xmm4
; SSE41-NEXT:    psrld %xmm3, %xmm4
; SSE41-NEXT:    pshuflw {{.*#+}} xmm2 = xmm2[0,1,1,1,4,5,6,7]
; SSE41-NEXT:    psrld %xmm2, %xmm0
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm4[0,1,2,3],xmm0[4,5,6,7]
; SSE41-NEXT:    pblendw {{.*#+}} xmm0 = xmm0[0,1],xmm5[2,3],xmm0[4,5],xmm5[6,7]
; SSE41-NEXT:    pmovsxbd {{.*#+}} xmm2 = [31,31,31,31]
; SSE41-NEXT:    pminud %xmm1, %xmm2
; SSE41-NEXT:    pcmpeqd %xmm1, %xmm2
; SSE41-NEXT:    pand %xmm2, %xmm0
; SSE41-NEXT:    retq
;
; AVX2-LABEL: combine_vec_lshr_commuted_clamped1:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpbroadcastd {{.*#+}} xmm2 = [31,31,31,31]
; AVX2-NEXT:    vpsrlvd %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpminud %xmm2, %xmm1, %xmm2
; AVX2-NEXT:    vpcmpeqd %xmm2, %xmm1, %xmm1
; AVX2-NEXT:    vpand %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: combine_vec_lshr_commuted_clamped1:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpsrlvd %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    retq
  %cmp.i = icmp uge <4 x i32> %amt, <i32 32, i32 32, i32 32, i32 32>
  %shr = lshr <4 x i32> %sh, %amt
  %1 = select <4 x i1> %cmp.i, <4 x i32> zeroinitializer, <4 x i32> %shr
  ret <4 x i32> %1
}