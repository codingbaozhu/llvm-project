; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 2
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+ndd -verify-machineinstrs | FileCheck %s

define i8 @neg8r(i8 noundef %a) {
; CHECK-LABEL: neg8r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negb %dil, %al
; CHECK-NEXT:    retq
entry:
  %neg = sub i8 0, %a
  ret i8 %neg
}

define i16 @neg16r(i16 noundef %a) {
; CHECK-LABEL: neg16r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negl %edi, %eax
; CHECK-NEXT:    # kill: def $ax killed $ax killed $eax
; CHECK-NEXT:    retq
entry:
  %neg = sub i16 0, %a
  ret i16 %neg
}

define i32 @neg32r(i32 noundef %a) {
; CHECK-LABEL: neg32r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negl %edi, %eax
; CHECK-NEXT:    retq
entry:
  %neg = sub i32 0, %a
  ret i32 %neg
}

define i64 @neg64r(i64 noundef %a) {
; CHECK-LABEL: neg64r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negq %rdi, %rax
; CHECK-NEXT:    retq
entry:
  %neg = sub i64 0, %a
  ret i64 %neg
}

define i8 @neg8m(ptr %ptr) {
; CHECK-LABEL: neg8m:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negb (%rdi), %al
; CHECK-NEXT:    retq
entry:
  %a = load i8, ptr %ptr
  %neg = sub i8 0, %a
  ret i8 %neg
}

define i16 @neg16m(ptr %ptr) {
; CHECK-LABEL: neg16m:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negw (%rdi), %ax
; CHECK-NEXT:    retq
entry:
  %a = load i16, ptr %ptr
  %neg = sub i16 0, %a
  ret i16 %neg
}

define i32 @neg32m(ptr %ptr) {
; CHECK-LABEL: neg32m:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negl (%rdi), %eax
; CHECK-NEXT:    retq
entry:
  %a = load i32, ptr %ptr
  %neg = sub i32 0, %a
  ret i32 %neg
}

define i64 @neg64m(ptr %ptr) {
; CHECK-LABEL: neg64m:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negq (%rdi), %rax
; CHECK-NEXT:    retq
entry:
  %a = load i64, ptr %ptr
  %neg = sub i64 0, %a
  ret i64 %neg
}

define i8 @uneg8r(i8 noundef %a) {
; CHECK-LABEL: uneg8r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negb %dil, %al
; CHECK-NEXT:    retq
entry:
  %t = call {i8, i1} @llvm.usub.with.overflow.i8(i8 0, i8 %a)
  %neg = extractvalue {i8, i1} %t, 0
  ret i8 %neg
}

define i16 @uneg16r(i16 noundef %a) {
; CHECK-LABEL: uneg16r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negl %edi, %eax
; CHECK-NEXT:    # kill: def $ax killed $ax killed $eax
; CHECK-NEXT:    retq
entry:
  %t = call {i16, i1} @llvm.usub.with.overflow.i16(i16 0, i16 %a)
  %neg = extractvalue {i16, i1} %t, 0
  ret i16 %neg
}

define i32 @uneg32r(i32 noundef %a) {
; CHECK-LABEL: uneg32r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negl %edi, %eax
; CHECK-NEXT:    retq
entry:
  %t = call {i32, i1} @llvm.usub.with.overflow.i32(i32 0, i32 %a)
  %neg = extractvalue {i32, i1} %t, 0
  ret i32 %neg
}

define i64 @uneg64r(i64 noundef %a) {
; CHECK-LABEL: uneg64r:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negq %rdi, %rax
; CHECK-NEXT:    retq
entry:
  %t = call {i64, i1} @llvm.usub.with.overflow.i64(i64 0, i64 %a)
  %neg = extractvalue {i64, i1} %t, 0
  ret i64 %neg
}

define i8 @uneg8m(ptr %ptr) {
; CHECK-LABEL: uneg8m:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negb (%rdi), %al
; CHECK-NEXT:    retq
entry:
  %a = load i8, ptr %ptr
  %t = call {i8, i1} @llvm.usub.with.overflow.i8(i8 0, i8 %a)
  %neg = extractvalue {i8, i1} %t, 0
  ret i8 %neg
}

define i16 @uneg16m(ptr %ptr) {
; CHECK-LABEL: uneg16m:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negw (%rdi), %ax
; CHECK-NEXT:    retq
entry:
  %a = load i16, ptr %ptr
  %t = call {i16, i1} @llvm.usub.with.overflow.i16(i16 0, i16 %a)
  %neg = extractvalue {i16, i1} %t, 0
  ret i16 %neg
}

define i32 @uneg32m(ptr %ptr) {
; CHECK-LABEL: uneg32m:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negl (%rdi), %eax
; CHECK-NEXT:    retq
entry:
  %a = load i32, ptr %ptr
  %t = call {i32, i1} @llvm.usub.with.overflow.i32(i32 0, i32 %a)
  %neg = extractvalue {i32, i1} %t, 0
  ret i32 %neg
}

define i64 @uneg64m(ptr %ptr) {
; CHECK-LABEL: uneg64m:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negq (%rdi), %rax
; CHECK-NEXT:    retq
entry:
  %a = load i64, ptr %ptr
  %t = call {i64, i1} @llvm.usub.with.overflow.i64(i64 0, i64 %a)
  %neg = extractvalue {i64, i1} %t, 0
  ret i64 %neg
}

declare {i8, i1} @llvm.usub.with.overflow.i8(i8, i8)
declare {i16, i1} @llvm.usub.with.overflow.i16(i16, i16)
declare {i32, i1} @llvm.usub.with.overflow.i32(i32, i32)
declare {i64, i1} @llvm.usub.with.overflow.i64(i64, i64)

define void @neg8m_legacy(ptr %ptr) {
; CHECK-LABEL: neg8m_legacy:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negb (%rdi)
; CHECK-NEXT:    retq
entry:
  %a = load i8, ptr %ptr
  %neg = sub i8 0, %a
  store i8 %neg, ptr %ptr
  ret void
}

define void @neg16m_legacy(ptr %ptr) {
; CHECK-LABEL: neg16m_legacy:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negw (%rdi)
; CHECK-NEXT:    retq
entry:
  %a = load i16, ptr %ptr
  %neg = sub i16 0, %a
  store i16 %neg, ptr %ptr
  ret void
}

define void @neg32m_legacy(ptr %ptr) {
; CHECK-LABEL: neg32m_legacy:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negl (%rdi)
; CHECK-NEXT:    retq
entry:
  %a = load i32, ptr %ptr
  %neg = sub i32 0, %a
  store i32 %neg, ptr %ptr
  ret void
}

define void @neg64m_legacy(ptr %ptr) {
; CHECK-LABEL: neg64m_legacy:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    negq (%rdi)
; CHECK-NEXT:    retq
entry:
  %a = load i64, ptr %ptr
  %neg = sub i64 0, %a
  store i64 %neg, ptr %ptr
  ret void
}
