unit AsmInstruction;

{$SCOPEDENUMS ON}

interface

uses
  stdlib,
  Generics.Collections;

const
  ASM_MAXBUFSIZE = 256;

type
  TAsmBuffer = array[0..ASM_MAXBUFSIZE-1] of AnsiChar;


  TAsmPrefix = (
    NONE,    // NO PREFIX
    LOCK,    // LOCK F0
    REP,     // REP/REPE/REPZ F3
    REPNEZ   // REPNE/REPNZ F2
  );

  TAsmMnemonic = (X86_INVALID = 0,
                  X86_AAA, X86_AAD, X86_AAM, X86_AAS,  X86_FABS, X86_ADC, X86_ADCX, X86_ADD,
                  X86_ADDPD, X86_ADDPS, X86_ADDSD, X86_ADDSS, X86_ADDSUBPD, X86_ADDSUBPS, X86_FADD,
                  X86_FIADD, X86_FADDP, X86_ADOX, X86_AESDECLAST, X86_AESDEC, X86_AESENCLAST, X86_AESENC,
                  X86_AESIMC, X86_AESKEYGENASSIST, X86_AND, X86_ANDN, X86_ANDNPD, X86_ANDNPS, X86_ANDPD,
                  X86_ANDPS, X86_ARPL, X86_BEXTR, X86_BLCFILL, X86_BLCI, X86_BLCIC, X86_BLCMSK, X86_BLCS,
                  X86_BLENDPD, X86_BLENDPS, X86_BLENDVPD, X86_BLENDVPS, X86_BLSFILL, X86_BLSI, X86_BLSIC,
                  X86_BLSMSK, X86_BLSR, X86_BOUND, X86_BSF, X86_BSR, X86_BSWAP, X86_BT, X86_BTC, X86_BTR,
                  X86_BTS, X86_BZHI, X86_CALL, X86_CBW, X86_CDQ, X86_CDQE, X86_FCHS, X86_CLAC, X86_CLC, X86_CLD,
                  X86_CLFLUSH, X86_CLFLUSHOPT, X86_CLGI, X86_CLI, X86_CLTS, X86_CLWB, X86_CMC, X86_CMOVA, X86_CMOVAE,
                  X86_CMOVB, X86_CMOVBE, X86_FCMOVBE, X86_FCMOVB, X86_CMOVE, X86_FCMOVE, X86_CMOVG, X86_CMOVGE,
                  X86_CMOVL, X86_CMOVLE, X86_FCMOVNBE, X86_FCMOVNB, X86_CMOVNE, X86_FCMOVNE, X86_CMOVNO, X86_CMOVNP,
                  X86_FCMOVNU, X86_CMOVNS, X86_CMOVO, X86_CMOVP, X86_FCMOVU, X86_CMOVS, X86_CMP, X86_CMPSB, X86_CMPSQ,
                  X86_CMPSW, X86_CMPXCHG16B, X86_CMPXCHG, X86_CMPXCHG8B, X86_COMISD, X86_COMISS, X86_FCOMP, X86_FCOMIP,
                  X86_FCOMI, X86_FCOM, X86_FCOS, X86_CPUID, X86_CQO, X86_CRC32, X86_CVTDQ2PD, X86_CVTDQ2PS, X86_CVTPD2DQ,
                  X86_CVTPD2PS, X86_CVTPS2DQ, X86_CVTPS2PD, X86_CVTSD2SI, X86_CVTSD2SS, X86_CVTSI2SD, X86_CVTSI2SS,
                  X86_CVTSS2SD, X86_CVTSS2SI, X86_CVTTPD2DQ, X86_CVTTPS2DQ, X86_CVTTSD2SI, X86_CVTTSS2SI, X86_CWD,
                  X86_CWDE, X86_DAA, X86_DAS, X86_DATA16, X86_DEC, X86_DIV, X86_DIVPD, X86_DIVPS, X86_FDIVR, X86_FIDIVR,
                  X86_FDIVRP, X86_DIVSD, X86_DIVSS, X86_FDIV, X86_FIDIV, X86_FDIVP, X86_DPPD, X86_DPPS, X86_RET, X86_ENCLS,
                  X86_ENCLU, X86_ENTER, X86_EXTRACTPS, X86_EXTRQ, X86_F2XM1, X86_LCALL, X86_LJMP, X86_FBLD, X86_FBSTP,
                  X86_FCOMPP, X86_FDECSTP, X86_FEMMS, X86_FFREE, X86_FICOM, X86_FICOMP, X86_FINCSTP, X86_FLDCW,
                  X86_FLDENV, X86_FLDL2E, X86_FLDL2T, X86_FLDLG2, X86_FLDLN2, X86_FLDPI, X86_FNCLEX, X86_FNINIT, X86_FNOP,
                  X86_FNSTCW, X86_FNSTSW, X86_FPATAN, X86_FPREM, X86_FPREM1, X86_FPTAN, X86_FFREEP, X86_FRNDINT, X86_FRSTOR,
                  X86_FNSAVE, X86_FSCALE, X86_FSETPM, X86_FSINCOS, X86_FNSTENV, X86_FXAM, X86_FXRSTOR, X86_FXRSTOR64,
                  X86_FXSAVE, X86_FXSAVE64, X86_FXTRACT, X86_FYL2X, X86_FYL2XP1, X86_MOVAPD, X86_MOVAPS, X86_ORPD,
                  X86_ORPS, X86_VMOVAPD, X86_VMOVAPS, X86_XORPD, X86_XORPS, X86_GETSEC, X86_HADDPD, X86_HADDPS,
                  X86_HLT, X86_HSUBPD, X86_HSUBPS, X86_IDIV, X86_FILD, X86_IMUL, X86_IN, X86_INC, X86_INSB,
                  X86_INSERTPS, X86_INSERTQ, X86_INSD, X86_INSW, X86_INT, X86_INT1, X86_INT3, X86_INTO, X86_INVD,
                  X86_INVEPT, X86_INVLPG, X86_INVLPGA, X86_INVPCID, X86_INVVPID, X86_IRET, X86_IRETD, X86_IRETQ,
                  X86_FISTTP, X86_FIST, X86_FISTP, X86_UCOMISD, X86_UCOMISS, X86_VCOMISD, X86_VCOMISS, X86_VCVTSD2SS,
                  X86_VCVTSI2SD, X86_VCVTSI2SS, X86_VCVTSS2SD, X86_VCVTTSD2SI, X86_VCVTTSD2USI, X86_VCVTTSS2SI,
                  X86_VCVTTSS2USI, X86_VCVTUSI2SD, X86_VCVTUSI2SS, X86_VUCOMISD, X86_VUCOMISS, X86_JAE, X86_JA,
                  X86_JBE, X86_JB, X86_JCXZ, X86_JECXZ, X86_JE, X86_JGE, X86_JG, X86_JLE, X86_JL, X86_JMP, X86_JNE,
                  X86_JNO, X86_JNP, X86_JNS, X86_JO, X86_JP, X86_JRCXZ, X86_JS, X86_KANDB, X86_KANDD, X86_KANDNB,
                  X86_KANDND, X86_KANDNQ, X86_KANDNW, X86_KANDQ, X86_KANDW, X86_KMOVB, X86_KMOVD, X86_KMOVQ, X86_KMOVW,
                  X86_KNOTB, X86_KNOTD, X86_KNOTQ, X86_KNOTW, X86_KORB, X86_KORD, X86_KORQ, X86_KORTESTB, X86_KORTESTD,
                  X86_KORTESTQ, X86_KORTESTW, X86_KORW, X86_KSHIFTLB, X86_KSHIFTLD, X86_KSHIFTLQ, X86_KSHIFTLW,
                  X86_KSHIFTRB, X86_KSHIFTRD, X86_KSHIFTRQ, X86_KSHIFTRW, X86_KUNPCKBW, X86_KXNORB, X86_KXNORD,
                  X86_KXNORQ, X86_KXNORW, X86_KXORB, X86_KXORD, X86_KXORQ, X86_KXORW, X86_LAHF, X86_LAR, X86_LDDQU,
                  X86_LDMXCSR, X86_LDS, X86_FLDZ, X86_FLD1, X86_FLD, X86_LEA, X86_LEAVE, X86_LES, X86_LFENCE, X86_LFS,
                  X86_LGDT, X86_LGS, X86_LIDT, X86_LLDT, X86_LMSW, X86_OR, X86_SUB, X86_XOR, X86_LODSB, X86_LODSD,
                  X86_LODSQ, X86_LODSW, X86_LOOP, X86_LOOPE, X86_LOOPNE, X86_RETF, X86_RETFQ, X86_LSL, X86_LSS,
                  X86_LTR, X86_XADD, X86_LZCNT, X86_MASKMOVDQU, X86_MAXPD, X86_MAXPS, X86_MAXSD, X86_MAXSS, X86_MFENCE,
                  X86_MINPD, X86_MINPS, X86_MINSD, X86_MINSS, X86_CVTPD2PI, X86_CVTPI2PD, X86_CVTPI2PS, X86_CVTPS2PI,
                  X86_CVTTPD2PI, X86_CVTTPS2PI, X86_EMMS, X86_MASKMOVQ, X86_MOVD, X86_MOVDQ2Q, X86_MOVNTQ, X86_MOVQ2DQ,
                  X86_MOVQ, X86_PABSB, X86_PABSD, X86_PABSW, X86_PACKSSDW, X86_PACKSSWB, X86_PACKUSWB, X86_PADDB,
                  X86_PADDD, X86_PADDQ, X86_PADDSB, X86_PADDSW, X86_PADDUSB, X86_PADDUSW, X86_PADDW, X86_PALIGNR,
                  X86_PANDN, X86_PAND, X86_PAVGB, X86_PAVGW, X86_PCMPEQB, X86_PCMPEQD, X86_PCMPEQW, X86_PCMPGTB,
                  X86_PCMPGTD, X86_PCMPGTW, X86_PEXTRW, X86_PHADDSW, X86_PHADDW, X86_PHADDD, X86_PHSUBD, X86_PHSUBSW,
                  X86_PHSUBW, X86_PINSRW, X86_PMADDUBSW, X86_PMADDWD, X86_PMAXSW, X86_PMAXUB, X86_PMINSW, X86_PMINUB,
                  X86_PMOVMSKB, X86_PMULHRSW, X86_PMULHUW, X86_PMULHW, X86_PMULLW, X86_PMULUDQ, X86_POR, X86_PSADBW,
                  X86_PSHUFB, X86_PSHUFW, X86_PSIGNB, X86_PSIGND, X86_PSIGNW, X86_PSLLD, X86_PSLLQ, X86_PSLLW, X86_PSRAD,
                  X86_PSRAW, X86_PSRLD, X86_PSRLQ, X86_PSRLW, X86_PSUBB, X86_PSUBD, X86_PSUBQ, X86_PSUBSB, X86_PSUBSW,
                  X86_PSUBUSB, X86_PSUBUSW, X86_PSUBW, X86_PUNPCKHBW, X86_PUNPCKHDQ, X86_PUNPCKHWD, X86_PUNPCKLBW,
                  X86_PUNPCKLDQ, X86_PUNPCKLWD, X86_PXOR, X86_MONITOR, X86_MONTMUL, X86_MOV, X86_MOVABS, X86_MOVBE,
                  X86_MOVDDUP, X86_MOVDQA, X86_MOVDQU, X86_MOVHLPS, X86_MOVHPD, X86_MOVHPS, X86_MOVLHPS, X86_MOVLPD,
                  X86_MOVLPS, X86_MOVMSKPD, X86_MOVMSKPS, X86_MOVNTDQA, X86_MOVNTDQ, X86_MOVNTI, X86_MOVNTPD, X86_MOVNTPS,
                  X86_MOVNTSD, X86_MOVNTSS, X86_MOVSB, X86_MOVSD, X86_MOVSHDUP, X86_MOVSLDUP, X86_MOVSQ, X86_MOVSS,
                  X86_MOVSW, X86_MOVSX, X86_MOVSXD, X86_MOVUPD, X86_MOVUPS, X86_MOVZX, X86_MPSADBW, X86_MUL,
                  X86_MULPD, X86_MULPS, X86_MULSD, X86_MULSS, X86_MULX, X86_FMUL, X86_FIMUL, X86_FMULP, X86_MWAIT,
                  X86_NEG, X86_NOP, X86_NOT, X86_OUT, X86_OUTSB, X86_OUTSD, X86_OUTSW, X86_PACKUSDW, X86_PAUSE,
                  X86_PAVGUSB, X86_PBLENDVB, X86_PBLENDW, X86_PCLMULQDQ, X86_PCMPEQQ, X86_PCMPESTRI, X86_PCMPESTRM,
                  X86_PCMPGTQ, X86_PCMPISTRI, X86_PCMPISTRM, X86_PCOMMIT, X86_PDEP, X86_PEXT, X86_PEXTRB, X86_PEXTRD,
                  X86_PEXTRQ, X86_PF2ID, X86_PF2IW, X86_PFACC, X86_PFADD, X86_PFCMPEQ, X86_PFCMPGE, X86_PFCMPGT,
                  X86_PFMAX, X86_PFMIN, X86_PFMUL, X86_PFNACC, X86_PFPNACC, X86_PFRCPIT1, X86_PFRCPIT2, X86_PFRCP,
                  X86_PFRSQIT1, X86_PFRSQRT, X86_PFSUBR, X86_PFSUB, X86_PHMINPOSUW, X86_PI2FD, X86_PI2FW, X86_PINSRB,
                  X86_PINSRD, X86_PINSRQ, X86_PMAXSB, X86_PMAXSD, X86_PMAXUD, X86_PMAXUW, X86_PMINSB, X86_PMINSD,
                  X86_PMINUD, X86_PMINUW, X86_PMOVSXBD, X86_PMOVSXBQ, X86_PMOVSXBW, X86_PMOVSXDQ, X86_PMOVSXWD,
                  X86_PMOVSXWQ, X86_PMOVZXBD, X86_PMOVZXBQ, X86_PMOVZXBW, X86_PMOVZXDQ, X86_PMOVZXWD, X86_PMOVZXWQ,
                  X86_PMULDQ, X86_PMULHRW, X86_PMULLD, X86_POP, X86_POPAW, X86_POPAL, X86_POPCNT, X86_POPF, X86_POPFD,
                  X86_POPFQ, X86_PREFETCH, X86_PREFETCHNTA, X86_PREFETCHT0, X86_PREFETCHT1, X86_PREFETCHT2, X86_PREFETCHW,
                  X86_PSHUFD, X86_PSHUFHW, X86_PSHUFLW, X86_PSLLDQ, X86_PSRLDQ, X86_PSWAPD, X86_PTEST, X86_PUNPCKHQDQ,
                  X86_PUNPCKLQDQ, X86_PUSH, X86_PUSHAW, X86_PUSHAL, X86_PUSHF, X86_PUSHFD, X86_PUSHFQ, X86_RCL,
                  X86_RCPPS, X86_RCPSS, X86_RCR, X86_RDFSBASE, X86_RDGSBASE, X86_RDMSR, X86_RDPMC, X86_RDRAND,
                  X86_RDSEED, X86_RDTSC, X86_RDTSCP, X86_ROL, X86_ROR, X86_RORX, X86_ROUNDPD, X86_ROUNDPS, X86_ROUNDSD,
                  X86_ROUNDSS, X86_RSM, X86_RSQRTPS, X86_RSQRTSS, X86_SAHF, X86_SAL, X86_SALC, X86_SAR, X86_SARX,
                  X86_SBB, X86_SCASB, X86_SCASD, X86_SCASQ, X86_SCASW, X86_SETAE, X86_SETA, X86_SETBE, X86_SETB,
                  X86_SETE, X86_SETGE, X86_SETG, X86_SETLE, X86_SETL, X86_SETNE, X86_SETNO, X86_SETNP, X86_SETNS,
                  X86_SETO, X86_SETP, X86_SETS, X86_SFENCE, X86_SGDT, X86_SHA1MSG1, X86_SHA1MSG2, X86_SHA1NEXTE,
                  X86_SHA1RNDS4, X86_SHA256MSG1, X86_SHA256MSG2, X86_SHA256RNDS2, X86_SHL, X86_SHLD, X86_SHLX,
                  X86_SHR, X86_SHRD, X86_SHRX, X86_SHUFPD, X86_SHUFPS, X86_SIDT, X86_FSIN, X86_SKINIT, X86_SLDT,
                  X86_SMSW, X86_SQRTPD, X86_SQRTPS, X86_SQRTSD, X86_SQRTSS, X86_FSQRT, X86_STAC, X86_STC,
                  X86_STD, X86_STGI, X86_STI, X86_STMXCSR, X86_STOSB, X86_STOSD, X86_STOSQ, X86_STOSW, X86_STR,
                  X86_FST, X86_FSTP, X86_FSTPNCE, X86_FXCH, X86_SUBPD, X86_SUBPS, X86_FSUBR, X86_FISUBR, X86_FSUBRP,
                  X86_SUBSD, X86_SUBSS, X86_FSUB, X86_FISUB, X86_FSUBP, X86_SWAPGS, X86_SYSCALL, X86_SYSENTER,
                  X86_SYSEXIT, X86_SYSRET, X86_T1MSKC, X86_TEST, X86_UD2, X86_FTST, X86_TZCNT, X86_TZMSK,
                  X86_FUCOMIP, X86_FUCOMI, X86_FUCOMPP, X86_FUCOMP, X86_FUCOM, X86_UD2B, X86_UNPCKHPD, X86_UNPCKHPS,
                  X86_UNPCKLPD, X86_UNPCKLPS, X86_VADDPD, X86_VADDPS, X86_VADDSD, X86_VADDSS, X86_VADDSUBPD,
                  X86_VADDSUBPS, X86_VAESDECLAST, X86_VAESDEC, X86_VAESENCLAST, X86_VAESENC, X86_VAESIMC,
                  X86_VAESKEYGENASSIST, X86_VALIGND, X86_VALIGNQ, X86_VANDNPD, X86_VANDNPS, X86_VANDPD,
                  X86_VANDPS, X86_VBLENDMPD, X86_VBLENDMPS, X86_VBLENDPD, X86_VBLENDPS, X86_VBLENDVPD, X86_VBLENDVPS,
                  X86_VBROADCASTF128, X86_VBROADCASTI32X4, X86_VBROADCASTI64X4, X86_VBROADCASTSD, X86_VBROADCASTSS,
                  X86_VCOMPRESSPD, X86_VCOMPRESSPS, X86_VCVTDQ2PD, X86_VCVTDQ2PS, X86_VCVTPD2DQX, X86_VCVTPD2DQ,
                  X86_VCVTPD2PSX, X86_VCVTPD2PS, X86_VCVTPD2UDQ, X86_VCVTPH2PS, X86_VCVTPS2DQ, X86_VCVTPS2PD,
                  X86_VCVTPS2PH, X86_VCVTPS2UDQ, X86_VCVTSD2SI, X86_VCVTSD2USI, X86_VCVTSS2SI, X86_VCVTSS2USI,
                  X86_VCVTTPD2DQX, X86_VCVTTPD2DQ, X86_VCVTTPD2UDQ, X86_VCVTTPS2DQ, X86_VCVTTPS2UDQ, X86_VCVTUDQ2PD,
                  X86_VCVTUDQ2PS, X86_VDIVPD, X86_VDIVPS, X86_VDIVSD, X86_VDIVSS, X86_VDPPD, X86_VDPPS,
    X86_VERR,
    X86_VERW,
    X86_VEXP2PD,
    X86_VEXP2PS,
    X86_VEXPANDPD,
    X86_VEXPANDPS,
    X86_VEXTRACTF128,
    X86_VEXTRACTF32X4,
    X86_VEXTRACTF64X4,
    X86_VEXTRACTI128,
    X86_VEXTRACTI32X4,
    X86_VEXTRACTI64X4,
    X86_VEXTRACTPS,
    X86_VFMADD132PD,
    X86_VFMADD132PS,
    X86_VFMADDPD,
    X86_VFMADD213PD,
    X86_VFMADD231PD,
    X86_VFMADDPS,
    X86_VFMADD213PS,
    X86_VFMADD231PS,
    X86_VFMADDSD,
    X86_VFMADD213SD,
    X86_VFMADD132SD,
    X86_VFMADD231SD,
    X86_VFMADDSS,
    X86_VFMADD213SS,
    X86_VFMADD132SS,
    X86_VFMADD231SS,
    X86_VFMADDSUB132PD,
    X86_VFMADDSUB132PS,
    X86_VFMADDSUBPD,
    X86_VFMADDSUB213PD,
    X86_VFMADDSUB231PD,
    X86_VFMADDSUBPS,
    X86_VFMADDSUB213PS,
    X86_VFMADDSUB231PS,
    X86_VFMSUB132PD,
    X86_VFMSUB132PS,
    X86_VFMSUBADD132PD,
    X86_VFMSUBADD132PS,
    X86_VFMSUBADDPD,
    X86_VFMSUBADD213PD,
    X86_VFMSUBADD231PD,
    X86_VFMSUBADDPS,
    X86_VFMSUBADD213PS,
    X86_VFMSUBADD231PS,
    X86_VFMSUBPD,
    X86_VFMSUB213PD,
    X86_VFMSUB231PD,
    X86_VFMSUBPS,
    X86_VFMSUB213PS,
    X86_VFMSUB231PS,
    X86_VFMSUBSD,
    X86_VFMSUB213SD,
    X86_VFMSUB132SD,
    X86_VFMSUB231SD,
    X86_VFMSUBSS,
    X86_VFMSUB213SS,
    X86_VFMSUB132SS,
    X86_VFMSUB231SS,
    X86_VFNMADD132PD,
    X86_VFNMADD132PS,
    X86_VFNMADDPD,
    X86_VFNMADD213PD,
    X86_VFNMADD231PD,
    X86_VFNMADDPS,
    X86_VFNMADD213PS,
    X86_VFNMADD231PS,
    X86_VFNMADDSD,
    X86_VFNMADD213SD,
    X86_VFNMADD132SD,
    X86_VFNMADD231SD,
    X86_VFNMADDSS,
    X86_VFNMADD213SS,
    X86_VFNMADD132SS,
    X86_VFNMADD231SS,
    X86_VFNMSUB132PD,
    X86_VFNMSUB132PS,
    X86_VFNMSUBPD,
    X86_VFNMSUB213PD,
    X86_VFNMSUB231PD,
    X86_VFNMSUBPS,
    X86_VFNMSUB213PS,
    X86_VFNMSUB231PS,
    X86_VFNMSUBSD,
    X86_VFNMSUB213SD,
    X86_VFNMSUB132SD,
    X86_VFNMSUB231SD,
    X86_VFNMSUBSS,
    X86_VFNMSUB213SS,
    X86_VFNMSUB132SS,
    X86_VFNMSUB231SS,
    X86_VFRCZPD,
    X86_VFRCZPS,
    X86_VFRCZSD,
    X86_VFRCZSS,
    X86_VORPD,
    X86_VORPS,
    X86_VXORPD,
    X86_VXORPS,
    X86_VGATHERDPD,
    X86_VGATHERDPS,
    X86_VGATHERPF0DPD,
    X86_VGATHERPF0DPS,
    X86_VGATHERPF0QPD,
    X86_VGATHERPF0QPS,
    X86_VGATHERPF1DPD,
    X86_VGATHERPF1DPS,
    X86_VGATHERPF1QPD,
    X86_VGATHERPF1QPS,
    X86_VGATHERQPD,
    X86_VGATHERQPS,
    X86_VHADDPD,
    X86_VHADDPS,
    X86_VHSUBPD,
    X86_VHSUBPS,
    X86_VINSERTF128,
    X86_VINSERTF32X4,
    X86_VINSERTF32X8,
    X86_VINSERTF64X2,
    X86_VINSERTF64X4,
    X86_VINSERTI128,
    X86_VINSERTI32X4,
    X86_VINSERTI32X8,
    X86_VINSERTI64X2,
    X86_VINSERTI64X4,
    X86_VINSERTPS,
    X86_VLDDQU,
    X86_VLDMXCSR,
    X86_VMASKMOVDQU,
    X86_VMASKMOVPD,
    X86_VMASKMOVPS,
    X86_VMAXPD,
    X86_VMAXPS,
    X86_VMAXSD,
    X86_VMAXSS,
    X86_VMCALL,
    X86_VMCLEAR,
    X86_VMFUNC,
    X86_VMINPD,
    X86_VMINPS,
    X86_VMINSD,
    X86_VMINSS,
    X86_VMLAUNCH,
    X86_VMLOAD,
    X86_VMMCALL,
    X86_VMOVQ,
    X86_VMOVDDUP,
    X86_VMOVD,
    X86_VMOVDQA32,
    X86_VMOVDQA64,
    X86_VMOVDQA,
    X86_VMOVDQU16,
    X86_VMOVDQU32,
    X86_VMOVDQU64,
    X86_VMOVDQU8,
    X86_VMOVDQU,
    X86_VMOVHLPS,
    X86_VMOVHPD,
    X86_VMOVHPS,
    X86_VMOVLHPS,
    X86_VMOVLPD,
    X86_VMOVLPS,
    X86_VMOVMSKPD,
    X86_VMOVMSKPS,
    X86_VMOVNTDQA,
    X86_VMOVNTDQ,
    X86_VMOVNTPD,
    X86_VMOVNTPS,
    X86_VMOVSD,
    X86_VMOVSHDUP,
    X86_VMOVSLDUP,
    X86_VMOVSS,
    X86_VMOVUPD,
    X86_VMOVUPS,
    X86_VMPSADBW,
    X86_VMPTRLD,
    X86_VMPTRST,
    X86_VMREAD,
    X86_VMRESUME,
    X86_VMRUN,
    X86_VMSAVE,
    X86_VMULPD,
    X86_VMULPS,
    X86_VMULSD,
    X86_VMULSS,
    X86_VMWRITE,
    X86_VMXOFF,
    X86_VMXON,
    X86_VPABSB,
    X86_VPABSD,
    X86_VPABSQ,
    X86_VPABSW,
    X86_VPACKSSDW,
    X86_VPACKSSWB,
    X86_VPACKUSDW,
    X86_VPACKUSWB,
    X86_VPADDB,
    X86_VPADDD,
    X86_VPADDQ,
    X86_VPADDSB,
    X86_VPADDSW,
    X86_VPADDUSB,
    X86_VPADDUSW,
    X86_VPADDW,
    X86_VPALIGNR,
    X86_VPANDD,
    X86_VPANDND,
    X86_VPANDNQ,
    X86_VPANDN,
    X86_VPANDQ,
    X86_VPAND,
    X86_VPAVGB,
    X86_VPAVGW,
    X86_VPBLENDD,
    X86_VPBLENDMB,
    X86_VPBLENDMD,
    X86_VPBLENDMQ,
    X86_VPBLENDMW,
    X86_VPBLENDVB,
    X86_VPBLENDW,
    X86_VPBROADCASTB,
    X86_VPBROADCASTD,
    X86_VPBROADCASTMB2Q,
    X86_VPBROADCASTMW2D,
    X86_VPBROADCASTQ,
    X86_VPBROADCASTW,
    X86_VPCLMULQDQ,
    X86_VPCMOV,
    X86_VPCMPB,
    X86_VPCMPD,
    X86_VPCMPEQB,
    X86_VPCMPEQD,
    X86_VPCMPEQQ,
    X86_VPCMPEQW,
    X86_VPCMPESTRI,
    X86_VPCMPESTRM,
    X86_VPCMPGTB,
    X86_VPCMPGTD,
    X86_VPCMPGTQ,
    X86_VPCMPGTW,
    X86_VPCMPISTRI,
    X86_VPCMPISTRM,
    X86_VPCMPQ,
    X86_VPCMPUB,
    X86_VPCMPUD,
    X86_VPCMPUQ,
    X86_VPCMPUW,
    X86_VPCMPW,
    X86_VPCOMB,
    X86_VPCOMD,
    X86_VPCOMPRESSD,
    X86_VPCOMPRESSQ,
    X86_VPCOMQ,
    X86_VPCOMUB,
    X86_VPCOMUD,
    X86_VPCOMUQ,
    X86_VPCOMUW,
    X86_VPCOMW,
    X86_VPCONFLICTD,
    X86_VPCONFLICTQ,
    X86_VPERM2F128,
    X86_VPERM2I128,
    X86_VPERMD,
    X86_VPERMI2D,
    X86_VPERMI2PD,
    X86_VPERMI2PS,
    X86_VPERMI2Q,
    X86_VPERMIL2PD,
    X86_VPERMIL2PS,
    X86_VPERMILPD,
    X86_VPERMILPS,
    X86_VPERMPD,
    X86_VPERMPS,
    X86_VPERMQ,
    X86_VPERMT2D,
    X86_VPERMT2PD,
    X86_VPERMT2PS,
    X86_VPERMT2Q,
    X86_VPEXPANDD,
    X86_VPEXPANDQ,
    X86_VPEXTRB,
    X86_VPEXTRD,
    X86_VPEXTRQ,
    X86_VPEXTRW,
    X86_VPGATHERDD,
    X86_VPGATHERDQ,
    X86_VPGATHERQD,
    X86_VPGATHERQQ,
    X86_VPHADDBD,
    X86_VPHADDBQ,
    X86_VPHADDBW,
    X86_VPHADDDQ,
    X86_VPHADDD,
    X86_VPHADDSW,
    X86_VPHADDUBD,
    X86_VPHADDUBQ,
    X86_VPHADDUBW,
    X86_VPHADDUDQ,
    X86_VPHADDUWD,
    X86_VPHADDUWQ,
    X86_VPHADDWD,
    X86_VPHADDWQ,
    X86_VPHADDW,
    X86_VPHMINPOSUW,
    X86_VPHSUBBW,
    X86_VPHSUBDQ,
    X86_VPHSUBD,
    X86_VPHSUBSW,
    X86_VPHSUBWD,
    X86_VPHSUBW,
    X86_VPINSRB,
    X86_VPINSRD,
    X86_VPINSRQ,
    X86_VPINSRW,
    X86_VPLZCNTD,
    X86_VPLZCNTQ,
    X86_VPMACSDD,
    X86_VPMACSDQH,
    X86_VPMACSDQL,
    X86_VPMACSSDD,
    X86_VPMACSSDQH,
    X86_VPMACSSDQL,
    X86_VPMACSSWD,
    X86_VPMACSSWW,
    X86_VPMACSWD,
    X86_VPMACSWW,
    X86_VPMADCSSWD,
    X86_VPMADCSWD,
    X86_VPMADDUBSW,
    X86_VPMADDWD,
    X86_VPMASKMOVD,
    X86_VPMASKMOVQ,
    X86_VPMAXSB,
    X86_VPMAXSD,
    X86_VPMAXSQ,
    X86_VPMAXSW,
    X86_VPMAXUB,
    X86_VPMAXUD,
    X86_VPMAXUQ,
    X86_VPMAXUW,
    X86_VPMINSB,
    X86_VPMINSD,
    X86_VPMINSQ,
    X86_VPMINSW,
    X86_VPMINUB,
    X86_VPMINUD,
    X86_VPMINUQ,
    X86_VPMINUW,
    X86_VPMOVDB,
    X86_VPMOVDW,
    X86_VPMOVM2B,
    X86_VPMOVM2D,
    X86_VPMOVM2Q,
    X86_VPMOVM2W,
    X86_VPMOVMSKB,
    X86_VPMOVQB,
    X86_VPMOVQD,
    X86_VPMOVQW,
    X86_VPMOVSDB,
    X86_VPMOVSDW,
    X86_VPMOVSQB,
    X86_VPMOVSQD,
    X86_VPMOVSQW,
    X86_VPMOVSXBD,
    X86_VPMOVSXBQ,
    X86_VPMOVSXBW,
    X86_VPMOVSXDQ,
    X86_VPMOVSXWD,
    X86_VPMOVSXWQ,
    X86_VPMOVUSDB,
    X86_VPMOVUSDW,
    X86_VPMOVUSQB,
    X86_VPMOVUSQD,
    X86_VPMOVUSQW,
    X86_VPMOVZXBD,
    X86_VPMOVZXBQ,
    X86_VPMOVZXBW,
    X86_VPMOVZXDQ,
    X86_VPMOVZXWD,
    X86_VPMOVZXWQ,
    X86_VPMULDQ,
    X86_VPMULHRSW,
    X86_VPMULHUW,
    X86_VPMULHW,
    X86_VPMULLD,
    X86_VPMULLQ,
    X86_VPMULLW,
    X86_VPMULUDQ,
    X86_VPORD,
    X86_VPORQ,
    X86_VPOR,
    X86_VPPERM,
    X86_VPROTB,
    X86_VPROTD,
    X86_VPROTQ,
    X86_VPROTW,
    X86_VPSADBW,
    X86_VPSCATTERDD,
    X86_VPSCATTERDQ,
    X86_VPSCATTERQD,
    X86_VPSCATTERQQ,
    X86_VPSHAB,
    X86_VPSHAD,
    X86_VPSHAQ,
    X86_VPSHAW,
    X86_VPSHLB,
    X86_VPSHLD,
    X86_VPSHLQ,
    X86_VPSHLW,
    X86_VPSHUFB,
    X86_VPSHUFD,
    X86_VPSHUFHW,
    X86_VPSHUFLW,
    X86_VPSIGNB,
    X86_VPSIGND,
    X86_VPSIGNW,
    X86_VPSLLDQ,
    X86_VPSLLD,
    X86_VPSLLQ,
    X86_VPSLLVD,
    X86_VPSLLVQ,
    X86_VPSLLW,
    X86_VPSRAD,
    X86_VPSRAQ,
    X86_VPSRAVD,
    X86_VPSRAVQ,
    X86_VPSRAW,
    X86_VPSRLDQ,
    X86_VPSRLD,
    X86_VPSRLQ,
    X86_VPSRLVD,
    X86_VPSRLVQ,
    X86_VPSRLW,
    X86_VPSUBB,
    X86_VPSUBD,
    X86_VPSUBQ,
    X86_VPSUBSB,
    X86_VPSUBSW,
    X86_VPSUBUSB,
    X86_VPSUBUSW,
    X86_VPSUBW,
    X86_VPTESTMD,
    X86_VPTESTMQ,
    X86_VPTESTNMD,
    X86_VPTESTNMQ,
    X86_VPTEST,
    X86_VPUNPCKHBW,
    X86_VPUNPCKHDQ,
    X86_VPUNPCKHQDQ,
    X86_VPUNPCKHWD,
    X86_VPUNPCKLBW,
    X86_VPUNPCKLDQ,
    X86_VPUNPCKLQDQ,
    X86_VPUNPCKLWD,
    X86_VPXORD,
    X86_VPXORQ,
    X86_VPXOR,
    X86_VRCP14PD,
    X86_VRCP14PS,
    X86_VRCP14SD,
    X86_VRCP14SS,
    X86_VRCP28PD,
    X86_VRCP28PS,
    X86_VRCP28SD,
    X86_VRCP28SS,
    X86_VRCPPS,
    X86_VRCPSS,
    X86_VRNDSCALEPD,
    X86_VRNDSCALEPS,
    X86_VRNDSCALESD,
    X86_VRNDSCALESS,
    X86_VROUNDPD,
    X86_VROUNDPS,
    X86_VROUNDSD,
    X86_VROUNDSS,
    X86_VRSQRT14PD,
    X86_VRSQRT14PS,
    X86_VRSQRT14SD,
    X86_VRSQRT14SS,
    X86_VRSQRT28PD,
    X86_VRSQRT28PS,
    X86_VRSQRT28SD,
    X86_VRSQRT28SS,
    X86_VRSQRTPS,
    X86_VRSQRTSS,
    X86_VSCATTERDPD,
    X86_VSCATTERDPS,
    X86_VSCATTERPF0DPD,
    X86_VSCATTERPF0DPS,
    X86_VSCATTERPF0QPD,
    X86_VSCATTERPF0QPS,
    X86_VSCATTERPF1DPD,
    X86_VSCATTERPF1DPS,
    X86_VSCATTERPF1QPD,
    X86_VSCATTERPF1QPS,
    X86_VSCATTERQPD,
    X86_VSCATTERQPS,
    X86_VSHUFPD,
    X86_VSHUFPS,
    X86_VSQRTPD,
    X86_VSQRTPS,
    X86_VSQRTSD,
    X86_VSQRTSS,
    X86_VSTMXCSR,
    X86_VSUBPD,
    X86_VSUBPS,
    X86_VSUBSD,
    X86_VSUBSS,
    X86_VTESTPD,
    X86_VTESTPS,
    X86_VUNPCKHPD,
    X86_VUNPCKHPS,
    X86_VUNPCKLPD,
    X86_VUNPCKLPS,
    X86_VZEROALL,
    X86_VZEROUPPER,
    X86_WAIT,
    X86_WBINVD,
    X86_WRFSBASE,
    X86_WRGSBASE,
    X86_WRMSR,
    X86_XABORT,
    X86_XACQUIRE,
    X86_XBEGIN,
    X86_XCHG,
    X86_XCRYPTCBC,
    X86_XCRYPTCFB,
    X86_XCRYPTCTR,
    X86_XCRYPTECB,
    X86_XCRYPTOFB,
    X86_XEND,
    X86_XGETBV,
    X86_XLATB,
    X86_XRELEASE,
    X86_XRSTOR,
    X86_XRSTOR64,
    X86_XRSTORS,
    X86_XRSTORS64,
    X86_XSAVE,
    X86_XSAVE64,
    X86_XSAVEC,
    X86_XSAVEC64,
    X86_XSAVEOPT,
    X86_XSAVEOPT64,
    X86_XSAVES,
    X86_XSAVES64,
    X86_XSETBV,
    X86_XSHA1,
    X86_XSHA256,
    X86_XSTORE,
    X86_XTEST,
    X86_FDISI8087_NOP,
    X86_FENI8087_NOP,

    // pseudo instructions
    X86_CMPSS,
    X86_CMPEQSS,
    X86_CMPLTSS,
    X86_CMPLESS,
    X86_CMPUNORDSS,
    X86_CMPNEQSS,
    X86_CMPNLTSS,
    X86_CMPNLESS,
    X86_CMPORDSS,

    X86_CMPSD,
    X86_CMPEQSD,
    X86_CMPLTSD,
    X86_CMPLESD,
    X86_CMPUNORDSD,
    X86_CMPNEQSD,
    X86_CMPNLTSD,
    X86_CMPNLESD,
    X86_CMPORDSD,

    X86_CMPPS,
    X86_CMPEQPS,
    X86_CMPLTPS,
    X86_CMPLEPS,
    X86_CMPUNORDPS,
    X86_CMPNEQPS,
    X86_CMPNLTPS,
    X86_CMPNLEPS,
    X86_CMPORDPS,

    X86_CMPPD,
    X86_CMPEQPD,
    X86_CMPLTPD,
    X86_CMPLEPD,
    X86_CMPUNORDPD,
    X86_CMPNEQPD,
    X86_CMPNLTPD,
    X86_CMPNLEPD,
    X86_CMPORDPD,

    X86_VCMPSS,
    X86_VCMPEQSS,
    X86_VCMPLTSS,
    X86_VCMPLESS,
    X86_VCMPUNORDSS,
    X86_VCMPNEQSS,
    X86_VCMPNLTSS,
    X86_VCMPNLESS,
    X86_VCMPORDSS,
    X86_VCMPEQ_UQSS,
    X86_VCMPNGESS,
    X86_VCMPNGTSS,
    X86_VCMPFALSESS,
    X86_VCMPNEQ_OQSS,
    X86_VCMPGESS,
    X86_VCMPGTSS,
    X86_VCMPTRUESS,
    X86_VCMPEQ_OSSS,
    X86_VCMPLT_OQSS,
    X86_VCMPLE_OQSS,
    X86_VCMPUNORD_SSS,
    X86_VCMPNEQ_USSS,
    X86_VCMPNLT_UQSS,
    X86_VCMPNLE_UQSS,
    X86_VCMPORD_SSS,
    X86_VCMPEQ_USSS,
    X86_VCMPNGE_UQSS,
    X86_VCMPNGT_UQSS,
    X86_VCMPFALSE_OSSS,
    X86_VCMPNEQ_OSSS,
    X86_VCMPGE_OQSS,
    X86_VCMPGT_OQSS,
    X86_VCMPTRUE_USSS,

    X86_VCMPSD,
    X86_VCMPEQSD,
    X86_VCMPLTSD,
    X86_VCMPLESD,
    X86_VCMPUNORDSD,
    X86_VCMPNEQSD,
    X86_VCMPNLTSD,
    X86_VCMPNLESD,
    X86_VCMPORDSD,
    X86_VCMPEQ_UQSD,
    X86_VCMPNGESD,
    X86_VCMPNGTSD,
    X86_VCMPFALSESD,
    X86_VCMPNEQ_OQSD,
    X86_VCMPGESD,
    X86_VCMPGTSD,
    X86_VCMPTRUESD,
    X86_VCMPEQ_OSSD,
    X86_VCMPLT_OQSD,
    X86_VCMPLE_OQSD,
    X86_VCMPUNORD_SSD,
    X86_VCMPNEQ_USSD,
    X86_VCMPNLT_UQSD,
    X86_VCMPNLE_UQSD,
    X86_VCMPORD_SSD,
    X86_VCMPEQ_USSD,
    X86_VCMPNGE_UQSD,
    X86_VCMPNGT_UQSD,
    X86_VCMPFALSE_OSSD,
    X86_VCMPNEQ_OSSD,
    X86_VCMPGE_OQSD,
    X86_VCMPGT_OQSD,
    X86_VCMPTRUE_USSD,

    X86_VCMPPS,
    X86_VCMPEQPS,
    X86_VCMPLTPS,
    X86_VCMPLEPS,
    X86_VCMPUNORDPS,
    X86_VCMPNEQPS,
    X86_VCMPNLTPS,
    X86_VCMPNLEPS,
    X86_VCMPORDPS,
    X86_VCMPEQ_UQPS,
    X86_VCMPNGEPS,
    X86_VCMPNGTPS,
    X86_VCMPFALSEPS,
    X86_VCMPNEQ_OQPS,
    X86_VCMPGEPS,
    X86_VCMPGTPS,
    X86_VCMPTRUEPS,
    X86_VCMPEQ_OSPS,
    X86_VCMPLT_OQPS,
    X86_VCMPLE_OQPS,
    X86_VCMPUNORD_SPS,
    X86_VCMPNEQ_USPS,
    X86_VCMPNLT_UQPS,
    X86_VCMPNLE_UQPS,
    X86_VCMPORD_SPS,
    X86_VCMPEQ_USPS,
    X86_VCMPNGE_UQPS,
    X86_VCMPNGT_UQPS,
    X86_VCMPFALSE_OSPS,
    X86_VCMPNEQ_OSPS,
    X86_VCMPGE_OQPS,
    X86_VCMPGT_OQPS,
    X86_VCMPTRUE_USPS,

    X86_VCMPPD,
    X86_VCMPEQPD,
    X86_VCMPLTPD,
    X86_VCMPLEPD,
    X86_VCMPUNORDPD,
    X86_VCMPNEQPD,
    X86_VCMPNLTPD,
    X86_VCMPNLEPD,
    X86_VCMPORDPD,
    X86_VCMPEQ_UQPD,
    X86_VCMPNGEPD,
    X86_VCMPNGTPD,
    X86_VCMPFALSEPD,
    X86_VCMPNEQ_OQPD,
    X86_VCMPGEPD,
    X86_VCMPGTPD,
    X86_VCMPTRUEPD,
    X86_VCMPEQ_OSPD,
    X86_VCMPLT_OQPD,
    X86_VCMPLE_OQPD,
    X86_VCMPUNORD_SPD,
    X86_VCMPNEQ_USPD,
    X86_VCMPNLT_UQPD,
    X86_VCMPNLE_UQPD,
    X86_VCMPORD_SPD,
    X86_VCMPEQ_USPD,
    X86_VCMPNGE_UQPD,
    X86_VCMPNGT_UQPD,
    X86_VCMPFALSE_OSPD,
    X86_VCMPNEQ_OSPD,
    X86_VCMPGE_OQPD,
    X86_VCMPGT_OQPD,
    X86_VCMPTRUE_USPD,
    X86_ENDING // marque o fim da lista de Mnemonics
);

  TAsmOperandType = (INVALID, Reg, Imm, Mem);

  TAsmRegister =
    (

        NONE,
        RAX, EAX, AX, AH, AL,
        RBX, EBX, BX, BH, BL,
        RCX, ECX, CX, CH, CL,
        RDX, EDX, DX, DH, DL);

//        BP, BPL,
//        CS, DI, DIL,
//        DS, EBP,
//        EDI, EFLAGS,
//        EIP, EIZ, ES, ESI, ESP,
//        FPSW, FS, GS, IP,
//        RBP, RDI,
//        RIP, RIZ, RSI, RSP, SI,
//        SIL, SP, SPL, SS, CR0,
//        CR1, CR2, CR3, CR4, CR5,
//        CR6, CR7, CR8, CR9, CR10,
//        CR11, CR12, CR13, CR14, CR15,
//        DR0, DR1, DR2, DR3, DR4,
//        DR5, DR6, DR7, DR8, DR9,
//        DR10, DR11, DR12, DR13, DR14,
//        DR15, FP0, FP1, FP2, FP3,
//        FP4, FP5, FP6, FP7,
//        K0, K1, K2, K3, K4,
//        K5, K6, K7, MM0, MM1,
//        MM2, MM3, MM4, MM5, MM6,
//        MM7, R8, R9, R10, R11,
//        R12, R13, R14, R15,
//        ST0, ST1, ST2, ST3,
//        ST4, ST5, ST6, ST7,
//        XMM0, XMM1, XMM2, XMM3, XMM4,
//        XMM5, XMM6, XMM7, XMM8, XMM9,
//        XMM10, XMM11, XMM12, XMM13, XMM14,
//        XMM15, XMM16, XMM17, XMM18, XMM19,
//        XMM20, XMM21, XMM22, XMM23, XMM24,
//        XMM25, XMM26, XMM27, XMM28, XMM29,
//        XMM30, XMM31, YMM0, YMM1, YMM2,
//        YMM3, YMM4, YMM5, YMM6, YMM7,
//        YMM8, YMM9, YMM10, YMM11, YMM12,
//        YMM13, YMM14, YMM15, YMM16, YMM17,
//        YMM18, YMM19, YMM20, YMM21, YMM22,
//        YMM23, YMM24, YMM25, YMM26, YMM27,
//        YMM28, YMM29, YMM30, YMM31, ZMM0,
//        ZMM1, ZMM2, ZMM3, ZMM4, ZMM5,
//        ZMM6, ZMM7, ZMM8, ZMM9, ZMM10,
//        ZMM11, ZMM12, ZMM13, ZMM14, ZMM15,
//        ZMM16, ZMM17, ZMM18, ZMM19, ZMM20,
//        ZMM21, ZMM22, ZMM23, ZMM24, ZMM25,
//        ZMM26, ZMM27, ZMM28, ZMM29, ZMM30,
//        ZMM31, R8B, R9B, R10B, R11B,
//        R12B, R13B, R14B, R15B, R8D,
//        R9D, R10D, R11D, R12D, R13D,
//        R14D, R15D, R8W, R9W, R10W,
//        R11W, R12W, R13W, R14W, R15W,
//        ENDING
//    );

  TAsmOpSize = (
    UNSET,     // No size set
    BYTE,      // Byte
    WORD,      // Word
    DWORD,     // Double Word
    FWORD,     // Far word 48bits
    QWORD,     // Quad Word
    TBYTE,     // FPU 80bits
    DQWORD,    // Double quad word
    XMMWORD,   // XMM Word
    YMMWORD,   // YMM Word
    ZMMWORD,   // ZMM Word
    _32_64     // 32 or 64 bits
  );

  TAsmValue = record
    Value: Int64;
    Signed: Boolean;
  end;

  TAsmSegment = (INVALID,
                 CS, SS, DS,
                 ES, FS, GS);

  TAsmMemory = record
    Segment: TAsmSegment;
    Base: TAsmRegister;
    Index: TAsmRegister;
    Scale: TAsmValue; //TODO: este � o caminho certo?
    Disp: TAsmValue;
  end;

  TAsmOperand = record
    Size: TAsmOpSize;
    case Type_: TAsmOperandType of
      TAsmOperandType.Reg: (Reg: TAsmRegister);
      TAsmOperandType.Imm: (Imm: TAsmValue);
      TAsmOperandType.Mem: (Mem: TAsmMemory);
  end;

  TAsmInstructionPtr = ^TAsmInstruction;
  TAsmInstruction = record
    Mnemonic: TAsmMnemonic;
    OperandCount: Integer;
    Operands: array[0..3] of TAsmOperand;
    Prefix: TAsmPrefix;
    Address: UInt64;
    Size: UInt16;
    Bytes: array[0..15] of UInt8;
    Flags: UInt64;
    Str: TAsmBuffer;
  end;


  TIntermediateTable = record
    Item: array of TAsmInstructionPtr;
    Count: integer;
    Size: integer;
  end;


  TAsmRegisterType = (NONE,
                      BIT8, BIT16, BIT32, BIT64,
                      MMX, XMM, YMM, ZMM, SEGMENT,
                      OPMASK, CONTROL, DEBUG, BOUND);


  TAsmArch = (NONE,
              x8086, x186, x286, x386, x486, PENTIUM,
              P6, MMX, SSE, SSE2, SSE3, SSSE3, SSE4_1,
              SSE4_2, SSE4A, SSE5, AVX, AVX2, AVX512_F,
              AVX512_CD, AVX512_ER, AVX512_PF, AVX512_BW,
              AVX512_DQ, AVX512_VL, AVX512_IFMA, AVX512_VBMI,
              AVX512_VPOPCNTDQ, AVX512_4VNNIW, AVX512_4FMAPS,
              AVX512_VBMI2, AVX512_VNNI, AVX512_BITALG,
              AVX512_GFNI, AVX512_VAES, AVX512_VPCLMULQDQ,
              ADX, AES, VMX, BMI1, BMI2, F16C,
              FMA, FSGSBASE, HLE, INVPCID, SHA,
              RTM, MPX, PCLMULQDQ, LZCNT, PREFETCHWT1,
              PRFCHW, RDPID, RDRAND, RDSEED, XSAVEOPT,
              SGX1, SGX2, SMX, CLDEMOTE, MOVDIR64B,
              MOVDIRI, PCONFIG, WAITPKG, x64, IA64,
              UNDOC, AMD, TBM, x3DNOW, CYRIX, CYRIXM);

  TAsmRegisterDef = record
    Name: AnsiString;
    Type_: TAsmRegisterType;
    Size: TAsmOpSize;
    Arch: TAsmArch;
    Documentation: string;
  end;

  TAsmOpSizeTableItem = record
    Name: string;
    Size: TAsmOpSize;
    Bytes: Integer;
    Bits: Integer;
  end;


const
  AsmRegisterTableDef: array[TAsmRegister] of TAsmRegisterDef = (
     (Name: 'NONE'; Type_: TAsmRegisterType.NONE; Size: TAsmOpSize.UNSET; Arch: TAsmArch.NONE;  Documentation: ''),
     (Name: 'RAX'; Type_: TAsmRegisterType.BIT64; Size: TAsmOpSize.QWORD; Arch: TAsmArch.x64;  Documentation: ''),
     (Name: 'EAX'; Type_: TAsmRegisterType.BIT32; Size: TAsmOpSize.DWORD; Arch: TAsmArch.x386;  Documentation: ''),
     (Name: 'AX';  Type_: TAsmRegisterType.BIT16; Size: TAsmOpSize.WORD; Arch: TAsmArch.x8086; Documentation: ''),
     (Name: 'AH';  Type_: TAsmRegisterType.BIT8;  Size: TAsmOpSize.BYTE;  Arch: TAsmArch.x8086; Documentation: ''),
     (Name: 'AL';  Type_: TAsmRegisterType.BIT8;  Size: TAsmOpSize.BYTE;  Arch: TAsmArch.x8086; Documentation: ''),

     (Name: 'RCX'; Type_: TAsmRegisterType.BIT64; Size: TAsmOpSize.QWORD; Arch: TAsmArch.x64;  Documentation: ''),
     (Name: 'ECX'; Type_: TAsmRegisterType.BIT32; Size: TAsmOpSize.DWORD; Arch: TAsmArch.x386;  Documentation: ''),
     (Name: 'CX';  Type_: TAsmRegisterType.BIT16; Size: TAsmOpSize.WORD; Arch: TAsmArch.x8086; Documentation: ''),
     (Name: 'CH';  Type_: TAsmRegisterType.BIT8;  Size: TAsmOpSize.BYTE;  Arch: TAsmArch.x8086; Documentation: ''),
     (Name: 'CL';  Type_: TAsmRegisterType.BIT8;  Size: TAsmOpSize.BYTE;  Arch: TAsmArch.x8086; Documentation: ''),

     (Name: 'RDX'; Type_: TAsmRegisterType.BIT64; Size: TAsmOpSize.QWORD; Arch: TAsmArch.X64;  Documentation: ''),
     (Name: 'EDX'; Type_: TAsmRegisterType.BIT32; Size: TAsmOpSize.DWORD; Arch: TAsmArch.x386;  Documentation: ''),
     (Name: 'DX';  Type_: TAsmRegisterType.BIT16; Size: TAsmOpSize.WORD; Arch: TAsmArch.x8086; Documentation: ''),
     (Name: 'DH';  Type_: TAsmRegisterType.BIT8;  Size: TAsmOpSize.BYTE;  Arch: TAsmArch.x8086; Documentation: ''),
     (Name: 'DL';  Type_: TAsmRegisterType.BIT8;  Size: TAsmOpSize.BYTE;  Arch: TAsmArch.x8086; Documentation: ''),

     (Name: 'RBX'; Type_: TAsmRegisterType.BIT64; Size: TAsmOpSize.QWORD; Arch: TAsmArch.x64;  Documentation: ''),
     (Name: 'EBX'; Type_: TAsmRegisterType.BIT32; Size: TAsmOpSize.DWORD; Arch: TAsmArch.x386;  Documentation: ''),
     (Name: 'BX';  Type_: TAsmRegisterType.BIT16; Size: TAsmOpSize.WORD; Arch: TAsmArch.x8086; Documentation: ''),
     (Name: 'BH';  Type_: TAsmRegisterType.BIT8;  Size: TAsmOpSize.BYTE;  Arch: TAsmArch.x8086; Documentation: ''),
     (Name: 'BL';  Type_: TAsmRegisterType.BIT8;  Size: TAsmOpSize.BYTE;  Arch: TAsmArch.x8086; Documentation: '')
  );

  AsmOpSizeTable: array[TAsmOpsize.BYTE..TAsmOpsize._32_64] of TAsmOpSizeTableItem = (
     (Name: 'byte'; Size: TAsmOpsize.BYTE; Bytes: 1; Bits: 8),
     (Name: 'word'; Size: TAsmOpsize.WORD; Bytes: 2; Bits: 16),
     (Name: 'dword'; Size: TAsmOpsize.DWORD; Bytes: 4; Bits: 32),
     (Name: 'fword'; Size: TAsmOpsize.FWORD; Bytes: 6; Bits: 48),
     (Name: 'qword'; Size: TAsmOpsize.QWORD; Bytes: 8; Bits: 64),
     (Name: 'tbyte'; Size: TAsmOpsize.TBYTE; Bytes: 10; Bits: 80),
     (Name: 'dqword'; Size: TAsmOpsize.DQWORD; Bytes: 16; Bits: 128),
     (Name: 'xmmword'; Size: TAsmOpsize.xmmword; Bytes: 16; Bits: 128),
     (Name: 'ymmword'; Size: TAsmOpsize.YMMWORD; Bytes: 32; Bits: 256),
     (Name: 'zmmword'; Size: TAsmOpsize.ZMMWORD; Bytes: 64; Bits: 512),
     (Name: '32_64'; Size: TAsmOpsize._32_64; Bytes: 0; Bits: 0)
  );


implementation

end.
