---
layout:     post
title:      "Writing a Compiler Frontend with LLVM"
date:       2025-12-01
categories: articles
tag:        "Article"
header:     headers/bf.png
header_rendering: auto
separate_banner: true
banner_header: bf/bf-banner.png
---

Compilers take source code written in an input language, like C or Go, and translate it into a target assembly language for architectures like x86 and ARM. Naively, when we introduce a new language, we would write a compiler for each architecture it targets, and symmetrically write many new compilers for each new architecture. Instead, we introduce a universal *intermediate representation* (IR) language, and split our compiler into a *frontend* that compiles from the input source to the IR, and a *backend* that compiles from the IR to assembly. Now, each input language needs only one frontend, and each target language only one backend, instead of the quadratic number we needed before.

The LLVM project is a collection of compiler tools, most famously producing the `clang` C/C++ compiler which uses the frontend/backend style, with the LLVM IR in the middle. As another example, Rust's `rustc` compiler is just a frontend that emits LLVM IR, and so Rust programs can reuse all of the hard work already put into optimising the LLVM backends.

I wanted to understand more about this IR and how it worked, and so I picked a simple language to write a compiler frontend for. I settled on [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck), possibly the simplest real language there is. With only eight commands, programs operate on a linear memory of coninguous bytes, and can move the data pointer left (`<`) or right (`>`), increment (`+`) or decrement (`-`) the value under the data pointer, get user input (`,`), or write output (`.`). Critical for Turing completeness, we also have constructs for conditional jumps (`[` and `]`) that allow us to implement loops.

To write a compiler frontend, we need to map these Brainfuck operations to the natural programming concepts of the LLVM IR. This IR is similar to assembly, except that registers are typed:

```llvm
%reg = add i32 4, 2
```

The IR requires a particular form called *single static assignment* (SSA), where almost all instructions return a value, and temporary variables can only be assigned once. This restricted form opens up a large number of optimisations for the LLVM backend to perform once we give it our IR.

Control flow is also slightly different. Unlike assembly we can't jump to arbitrary labelled instructions, but have to split our functions into a number of *basic blocks*. These must end in an instruction that changes the control flow, like branch (`br`) or return (`ret`), but all other instructions in them must not change the control flow. When we do a jump, we can only jump to the beginning of a basic block, not to the middle of it. This restricted form, again, allows the backend compiler to do many optimisations that it wouldn't otherwise.

As an extended example, let's see how my compiler frontend compiles the following Brainfuck code to LLVM IR. At a high level, this program adds six to the first cell (which starts initialised to zero), outputs this value, and then enters the loop, decrementing the cell repeatedly until it gets to zero, at which point we output this value and end the program.

```
++++++.[-].
```

> If you would like to follow along yourself, you can clone the [GitHub repository](https://github.com/benmandrew/bf) and run
> ```
> docker compose up
> ```
> which opens an interactive web interface at [https://localhost:8080](https://localhost:8080).

We start with the global variables, which are visible everywhere in the program. These are `data`, which points to the front of our contiguous array of bytes, and the data pointer `dp` which we will use to dynamically index into `data`. We also declare an *external function* `putchar` that allows us to write output, which will be linked in from the C standard library by the compiler backend later.

```llvm
@dp = global i32 0
@data = global [65536 x i8] zeroinitializer

declare i32 @putchar(i32)
```

We define the start of our main function, with the beginning of the first basic block labelled `entry`. Adding six to the current cell is a multi-step process.

1. First, as `dp` is a global variable, we must load its value into a register named `dptmp`.
2. Then, we must do pointer arithmetic to find the exact location pointed to by `dp`, combining `data` and `dp` with the `getelementptr` psuedo-instruction to get `data_ptr`.
3. We then load the value pointed to by `data_ptr` into `current_val`, add six to it to produce `addtmp`, and then store that value back into the memory location pointed to by `data_ptr`.

(Note that because of the SSA form, we had to generate a new temporary variable for each assignment.)

```llvm
define i32 @main() {
entry:
  %dptmp = load i32, ptr @dp, align 4
  %data_ptr = getelementptr [65536 x i8], ptr @data, i32 0, i32 %dptmp
  %current_val = load i8, ptr %data_ptr, align 1
  %addtmp = add i8 %current_val, 6
  store i8 %addtmp, ptr %data_ptr, align 1
...
```

This pattern is repeated for both writing to output, and performing the conditional jump. Note the labels on the final `br` instruction that say which basic blocks we can jump to.

```llvm
...
  %dptmp1 = load i32, ptr @dp, align 4
  %data_ptr2 = getelementptr [65536 x i8], ptr @data, i32 0, i32 %dptmp1
  %current_val3 = load i8, ptr %data_ptr2, align 1
  %extended_val = zext i8 %current_val3 to i32
  %callputchar_tmp = call i32 @putchar(i32 %extended_val)

  %dptmp4 = load i32, ptr @dp, align 4
  %data_ptr5 = getelementptr [65536 x i8], ptr @data, i32 0, i32 %dptmp4
  %current_val6 = load i8, ptr %data_ptr5, align 1
  %loopcond = icmp ne i8 %current_val6, 0
  br i1 %loopcond, label %entry7, label %exit
...
```

While re-reading the current value into a register may seem like wasted work, this redundancy is optimised away by the compiler backend. Below is the section of the ARM64 MacOS assembly produced by `clang` that corresponds to the addition and call to `putchar`; note that we are reusing the value already in register `w9`. (The full assembly dump is at the bottom of this post.)

```
...
    ldrb w9, [x19, x8]
    add  w9, w9, #6
    strb w9, [x19, x8]
    and  w0, w9, #0xff
    bl   _putchar
...
```

The next basic block corresponds to the inside of the loop that decrements the value in current cell. It follows the same pattern as above, but note how in the final `br` instruction we can either jump back to the beginning of the basic block, creating a loop, or jump to the `exit` basic block, which we will see below.

```llvm
entry7:                                           ; preds = %entry7, %entry
  %dptmp8 = load i32, ptr @dp, align 4
  %data_ptr9 = getelementptr [65536 x i8], ptr @data, i32 0, i32 %dptmp8
  %current_val10 = load i8, ptr %data_ptr9, align 1
  %subtmp = sub i8 %current_val10, 1
  store i8 %subtmp, ptr %data_ptr9, align 1
  %dptmp11 = load i32, ptr @dp, align 4
  %data_ptr12 = getelementptr [65536 x i8], ptr @data, i32 0, i32 %dptmp11
  %current_val13 = load i8, ptr %data_ptr12, align 1
  %loopcond14 = icmp ne i8 %current_val13, 0
  br i1 %loopcond14, label %entry7, label %exit
```

The final basic block of our `main` function again follows the same pattern, but instead of ending with a branch instruction, we *return* from the main function with `ret`, implicitly terminating the program.

```llvm
exit:                                             ; preds = %entry7, %entry
  %dptmp15 = load i32, ptr @dp, align 4
  %data_ptr16 = getelementptr [65536 x i8], ptr @data, i32 0, i32 %dptmp15
  %current_val17 = load i8, ptr %data_ptr16, align 1
  %extended_val18 = zext i8 %current_val17 to i32
  %callputchar_tmp19 = call i32 @putchar(i32 %extended_val18)
  ret i32 0
}
```

This code is obviously not generated by hand; instead the compiler frontend uses functions from the LLVM C library to generate the code in-memory. The library also includes functions for dumping the IR to text, as seen above.

## Links
- [`bf` GitHub repository](https://github.com/benmandrew/bf)
- [`bf` Docker Hub repository](https://hub.docker.com/repository/docker/benmandrew/bf/general)
- [Mapping High Level Constructs to LLVM IR](https://mapping-high-level-constructs-to-llvm-ir.readthedocs.io/en/latest/)
- [A Complete Guide to LLVM for Programming Language Creators](https://mukulrathi.com/create-your-own-programming-language/llvm-ir-cpp-api-tutorial/)
- [My First Language Frontend with LLVM Tutorial](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/)

## Full Assembly Code

Produced using `clang -O3 -S main.ll` on ARM-based MacOS. Note that if you do not use any optimisation flags, then `clang` will *not* optimise away the unnecessary reads from memory.

```
	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 15, 0
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
; %bb.0:                                ; %entry
	stp	x20, x19, [sp, #-32]!           ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
Lloh0:
	adrp	x19, _data@PAGE
Lloh1:
	add	x19, x19, _data@PAGEOFF
	adrp	x20, _dp@PAGE
	ldrsw	x8, [x20, _dp@PAGEOFF]
	ldrb	w9, [x19, x8]
	add	w9, w9, #6
	strb	w9, [x19, x8]
	and	w0, w9, #0xff
	bl	_putchar
	ldrsw	x8, [x20, _dp@PAGEOFF]
	ldrb	w9, [x19, x8]
	cbz	w9, LBB0_2
; %bb.1:                                ; %entry7.preheader
	strb	wzr, [x19, x8]
LBB0_2:                                 ; %exit
	mov	w0, #0                          ; =0x0
	bl	_putchar
	mov	w0, #0                          ; =0x0
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp], #32             ; 16-byte Folded Reload
	ret
	.loh AdrpAdd	Lloh0, Lloh1
                                        ; -- End function
	.globl	_dp                             ; @dp
.zerofill __DATA,__common,_dp,4,2
	.globl	_data                           ; @data
.zerofill __DATA,__common,_data,65536,4
.subsections_via_symbols
```
