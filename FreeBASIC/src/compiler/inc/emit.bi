#ifndef __EMIT_BI__
#define __EMIT_BI__

''	FreeBASIC - 32-bit BASIC Compiler.
''	Copyright (C) 2004-2006 Andre Victor T. Vicentini (av1ctor@yahoo.com.br)
''
''	This program is free software; you can redistribute it and/or modify
''	it under the terms of the GNU General Public License as published by
''	the Free Software Foundation; either version 2 of the License, or
''	(at your option) any later version.
''
''	This program is distributed in the hope that it will be useful,
''	but WITHOUT ANY WARRANTY; without even the implied warranty of
''	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
''	GNU General Public License for more details.
''
''	You should have received a copy of the GNU General Public License
''	along with this program; if not, write to the Free Software
''	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA.


#include once "inc\flist.bi"
#include once "inc\reg.bi"
#include once "inc\ast.bi"
#include once "inc\ir.bi"

const NEWLINE = "\r\n"

const EMIT_INITNODES	= 1024
const EMIT_INITVREGNODES= EMIT_INITNODES*4

'#ifdef TARGET_X86
const EMIT_REGCLASSES	= 2						'' assuming FB_DATACLASS_ will start at 0!
const EMIT_LOCSTART 	= 0
const EMIT_ARGSTART 	= FB_POINTERSIZE + FB_INTEGERSIZE '' skip return address + saved ebp

enum EMITREG_ENUM
	EMIT_REG_FP0	= 0
	EMIT_REG_FP1
	EMIT_REG_FP2
	EMIT_REG_FP3
	EMIT_REG_FP4
	EMIT_REG_FP5
	EMIT_REG_FP6
	EMIT_REG_FP7

	EMIT_REG_EDX	= EMIT_REG_FP0				'' aliased
	EMIT_REG_EDI
	EMIT_REG_ESI
	EMIT_REG_ECX
	EMIT_REG_EBX
	EMIT_REG_EAX
	EMIT_REG_EBP
	EMIT_REG_ESP
end enum
'#endif

'' section types
enum EMITSECTYPE_ENUM
	EMIT_SECTYPE_CONST
	EMIT_SECTYPE_DATA
	EMIT_SECTYPE_BSS
	EMIT_SECTYPE_CODE
	EMIT_SECTYPE_DIRECTIVE
    EMIT_SECTYPE_CONSTRUCTOR
    EMIT_SECTYPE_DESTRUCTOR
end enum

enum EMIT_NODEOP_ENUM
	'' load
	EMIT_OP_LOADI2I, EMIT_OP_LOADF2I, EMIT_OP_LOADL2I
	EMIT_OP_LOADI2F, EMIT_OP_LOADF2F, EMIT_OP_LOADL2F
	EMIT_OP_LOADI2L, EMIT_OP_LOADF2L, EMIT_OP_LOADL2L

	'' store
	EMIT_OP_STORI2I, EMIT_OP_STORF2I, EMIT_OP_STORL2I
	EMIT_OP_STORI2F, EMIT_OP_STORF2F, EMIT_OP_STORL2F
	EMIT_OP_STORI2L, EMIT_OP_STORF2L, EMIT_OP_STORL2L

	'' bop
	EMIT_OP_MOVI, EMIT_OP_MOVF, EMIT_OP_MOVL
	EMIT_OP_ADDI, EMIT_OP_ADDF, EMIT_OP_ADDL
	EMIT_OP_SUBI, EMIT_OP_SUBF, EMIT_OP_SUBL
	EMIT_OP_MULI, EMIT_OP_MULF, EMIT_OP_MULL, EMIT_OP_SMULI
	EMIT_OP_DIVI, EMIT_OP_DIVF, EMIT_OP_DIVL
	EMIT_OP_MODI, EMIT_OP_MODF, EMIT_OP_MODL
	EMIT_OP_SHLI, EMIT_OP_SHLL
	EMIT_OP_SHRI, EMIT_OP_SHRL
	EMIT_OP_ANDI, EMIT_OP_ANDL
	EMIT_OP_ORI , EMIT_OP_ORL
	EMIT_OP_XORI, EMIT_OP_XORL
	EMIT_OP_EQVI, EMIT_OP_EQVL
	EMIT_OP_IMPI, EMIT_OP_IMPL

	EMIT_OP_ATN2
	EMIT_OP_POW

	EMIT_OP_ADDROF
	EMIT_OP_DEREF

	'' rel
	EMIT_OP_CGTI, EMIT_OP_CGTF, EMIT_OP_CGTL
	EMIT_OP_CLTI, EMIT_OP_CLTF, EMIT_OP_CLTL
	EMIT_OP_CEQI, EMIT_OP_CEQF, EMIT_OP_CEQL
	EMIT_OP_CNEI, EMIT_OP_CNEF, EMIT_OP_CNEL
	EMIT_OP_CGEI, EMIT_OP_CGEF, EMIT_OP_CGEL
	EMIT_OP_CLEI, EMIT_OP_CLEF, EMIT_OP_CLEL

	'' uop
	EMIT_OP_NEGI, EMIT_OP_NEGF, EMIT_OP_NEGL
	EMIT_OP_NOTI, EMIT_OP_NOTL
	EMIT_OP_ABSI, EMIT_OP_ABSF, EMIT_OP_ABSL
	EMIT_OP_SGNI, EMIT_OP_SGNF, EMIT_OP_SGNL

	EMIT_OP_SIN, EMIT_OP_ASIN
	EMIT_OP_COS, EMIT_OP_ACOS
	EMIT_OP_TAN, EMIT_OP_ATAN
	EMIT_OP_SQRT
	EMIT_OP_LOG
	EMIT_OP_FLOOR
	EMIT_OP_XCHGTOS

	EMIT_OP_ALIGN
	EMIT_OP_STKALIGN

	EMIT_OP_PUSHI, EMIT_OP_PUSHF, EMIT_OP_PUSHL
	EMIT_OP_POPI, EMIT_OP_POPF, EMIT_OP_POPL
	EMIT_OP_PUSHUDT

	'' branch
	EMIT_OP_CALL
	EMIT_OP_CALLPTR
    EMIT_OP_BRANCH
    EMIT_OP_JUMP
    EMIT_OP_JUMPPTR
	EMIT_OP_RET

	'' misc
	EMIT_OP_LABEL
	EMIT_OP_PUBLIC
	EMIT_OP_LIT
	EMIT_OP_JMPTB

	'' mem
	EMIT_OP_MEMMOVE
	EMIT_OP_MEMSWAP
	EMIT_OP_MEMCLEAR
	EMIT_OP_STKCLEAR

	EMIT_MAXOPS
end enum

enum EMIT_NODECLASS_ENUM
	EMIT_NODECLASS_BOP
	EMIT_NODECLASS_UOP
	EMIT_NODECLASS_REL
	EMIT_NODECLASS_STK
	EMIT_NODECLASS_BRC
	EMIT_NODECLASS_LIT
	EMIT_NODECLASS_JTB
	EMIT_NODECLASS_SOP
	EMIT_NODECLASS_MEM
end enum

type EMIT_BOPNODE
	op			as integer
	dvreg		as IRVREG ptr
	svreg		as IRVREG ptr
end type

type EMIT_UOPNODE
	op			as integer
	dvreg		as IRVREG ptr
end type

type EMIT_RELNODE
	op			as integer
	rvreg		as IRVREG ptr
	label		as FBSYMBOL ptr
	dvreg		as IRVREG ptr
	svreg		as IRVREG ptr
end type

type EMIT_STKNODE
	op			as integer
	vreg		as IRVREG ptr
	extra		as integer
end type

type EMIT_BRCNODE
	op			as integer
	vreg		as IRVREG ptr
	sym			as FBSYMBOL ptr
	extra		as integer
end type

type EMIT_SOPNODE
	op			as integer
	sym			as FBSYMBOL ptr
end type

type EMIT_LITNODE
	text		as zstring ptr
end type

type EMIT_JTBNODE
	dtype		as integer
	text		as zstring ptr
end type

type EMIT_MEMNODE
	op			as integer
	dvreg		as IRVREG ptr
	svreg		as IRVREG ptr
	bytes		as integer
	extra		as integer
end type

type EMIT_NODE
	class							as EMIT_NODECLASS_ENUM

	union
		bop							as EMIT_BOPNODE
		uop							as EMIT_UOPNODE
		rel							as EMIT_RELNODE
		stk						 	as EMIT_STKNODE
		brc							as EMIT_BRCNODE
		sop							as EMIT_SOPNODE
		lit							as EMIT_LITNODE
		jtb							as EMIT_JTBNODE
		mem							as EMIT_MEMNODE
	end union

	regFreeTB(EMIT_REGCLASSES-1) 	as REG_FREETB
end type


type EMIT_BOPCB as sub( byval dvreg as IRVREG ptr, _
						byval svreg as IRVREG ptr )

type EMIT_UOPCB as sub( byval dvreg as IRVREG ptr )

type EMIT_RELCB as sub( byval rvreg as IRVREG ptr, _
						byval label as FBSYMBOL ptr, _
						byval dvreg as IRVREG ptr, _
						byval svreg as IRVREG ptr )

type EMIT_STKCB as sub( byval vreg as IRVREG ptr, _
						byval extra as integer )

type EMIT_BRCCB as sub( byval vreg as IRVREG ptr, _
						byval sym as FBSYMBOL ptr, _
						byval extra as integer )

type EMIT_SOPCB as sub( byval sym as FBSYMBOL ptr )

type EMIT_LITCB as sub( byval text as zstring ptr )

type EMIT_JTBCB as sub( byval dtype as integer, _
						byval text as zstring ptr )

type EMIT_MEMCB as sub( byval dvreg as IRVREG ptr, _
						byval svreg as IRVREG ptr, _
						byval bytes as integer, _
						byval extra as integer )


type EMITCTX
	inited								as integer

	pos									as integer			'' to help debugging

	regTB(0 to EMIT_REGCLASSES-1) 		as REGCLASS ptr		'' reg classes

	'' node tb
	nodeTB								as TFLIST
	vregTB								as TFLIST
	curnode								as EMIT_NODE ptr

	regUsedTB(EMIT_REGCLASSES-1) 		as REG_FREETB       '' keep track of register usage

	'' platform-dependent
	dataend								as integer

	lastsection							as integer

	keyinited							as integer
	keyhash								as THASH

    '' header flags, TRUE= emited already
    bssheader							as integer
    conheader							as integer
    datheader							as integer
    expheader       					as integer
end type

''
''
''
declare sub 		emitInit			( )

declare sub 		emitEnd				( )

declare function 	emitOpen			( ) as integer

declare sub 		emitClose			( byval tottime as double )

declare function 	emitGetRegClass		( byval dclass as integer ) as REGCLASS ptr

declare	function 	emitGetPos 			( ) as integer

declare function 	emitIsKeyword		( byval text as zstring ptr ) as integer

declare sub 		emitProcBegin		( byval proc as FBSYMBOL ptr )

declare sub 		emitProcEnd			( byval proc as FBSYMBOL ptr )

declare function 	emitGetVarName		( byval s as FBSYMBOL ptr ) as string

declare function 	emitIsRegPreserved 	( byval dclass as integer, _
										  byval reg as integer ) as integer

declare sub			emitGetResultReg 	( byval dtype as integer, _
										  byval dclass as integer, _
										  byref r1 as integer, _
										  byref r2 as integer )

declare function 	emitGetFreePreservedReg( byval dclass as integer ) as integer

declare function 	emitAllocLocal		( byval proc as FBSYMBOL ptr, _
										  byval lgt as integer, _
										  byref ofs as integer ) as zstring ptr

declare sub 		emitFreeLocal		( byval proc as FBSYMBOL ptr, _
										  byval lgt as integer )

declare function 	emitAllocArg		( byval proc as FBSYMBOL ptr, _
										  byval lgt as integer, _
										  byref ofs as integer ) as zstring ptr

declare sub 		emitFreeArg			( byval proc as FBSYMBOL ptr, _
										  byval lgt as integer )

declare sub 		emitPROCHEADER		( byval proc as FBSYMBOL ptr, _
										  byval initlabel as FBSYMBOL ptr )

declare sub 		emitPROCFOOTER		( byval proc as FBSYMBOL ptr, _
										  byval bytestopop as integer, _
										  byval initlabel as FBSYMBOL ptr, _
										  byval exitlabel as FBSYMBOL ptr )

declare function 	emitSCOPEHEADER		( byval s as FBSYMBOl ptr ) as EMIT_NODE ptr
declare function 	emitSCOPEFOOTER		( byval s as FBSYMBOl ptr ) as EMIT_NODE ptr

declare function	emitASM				( byval text as zstring ptr ) as EMIT_NODE ptr

declare function	emitCOMMENT			( byval text as zstring ptr ) as EMIT_NODE ptr

declare function	emitLIT				( byval text as zstring ptr ) as EMIT_NODE ptr

declare function	emitJMPTB			( byval dtype as integer, _
										  byval text as zstring ptr ) as EMIT_NODE ptr

declare function	emitALIGN			( byval bytes as integer ) as EMIT_NODE ptr

declare function	emitSTACKALIGN		( byval bytes as integer ) as EMIT_NODE ptr

declare function	emitCALL			( byval label as FBSYMBOL ptr, _
										  byval bytestopop as integer ) as EMIT_NODE ptr

declare function	emitCALLPTR			( byval svreg as IRVREG ptr, _
										  byval bytestopop as integer ) as EMIT_NODE ptr

declare function	emitJUMP			( byval label as FBSYMBOL ptr ) as EMIT_NODE ptr

declare function	emitJUMPPTR			( byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitLABEL			( byval label as FBSYMBOL ptr ) as EMIT_NODE ptr

declare function	emitRET				( byval bytestopop as integer ) as EMIT_NODE ptr

declare function	emitPUBLIC			( byval label as FBSYMBOL ptr ) as EMIT_NODE ptr

declare function	emitBRANCH			( byval op as integer, _
										  byval label as FBSYMBOL ptr ) as EMIT_NODE ptr

declare function	emitXchgTOS			( byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitMOV				( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitSTORE			( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitLOAD			( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitADD				( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitSUB				( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitMUL				( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitDIV				( byval dvreg as IRVREG ptr, _
		     							  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitINTDIV			( byval dvreg as IRVREG ptr, _
		     							  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitMOD				( byval dvreg as IRVREG ptr, _
		     							  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitSHL				( byval dvreg as IRVREG ptr, _
			 					  	 	  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitSHR				( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitAND				( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitOR				( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitXOR				( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitEQV				( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitIMP				( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitADDROF			( byval dvreg as IRVREG ptr, _
			    						  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitDEREF			( byval dvreg as IRVREG ptr, _
			    						  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitGT				( byval rvreg as IRVREG ptr, _
										  byval label as FBSYMBOL ptr, _
								  		  byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitLT				( byval rvreg as IRVREG ptr, _
										  byval label as FBSYMBOL ptr, _
								  		  byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitEQ				( byval rvreg as IRVREG ptr, _
										  byval label as FBSYMBOL ptr, _
								  		  byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitNE				( byval rvreg as IRVREG ptr, _
										  byval label as FBSYMBOL ptr, _
								  		  byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitLE				( byval rvreg as IRVREG ptr, _
										  byval label as FBSYMBOL ptr, _
								  		  byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitGE				( byval rvreg as IRVREG ptr, _
										  byval label as FBSYMBOL ptr, _
								  		  byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitATN2			( byval dvreg as IRVREG ptr, _
			   							  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitPOW				( byval dvreg as IRVREG ptr, _
			   							  byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitNEG				( byval dvreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitNOT				( byval dvreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitABS				( byval dvreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitSGN				( byval dvreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitSIN				( byval dvreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitASIN			( byval dvreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitCOS				( byval dvreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitACOS			( byval dvreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitTAN				( byval dvreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitATAN			( byval dvreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitSQRT			( byval dvreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitLOG				( byval dvreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitFLOOR			( byval dvreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitPUSH			( byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitPUSHUDT			( byval svreg as IRVREG ptr, _
										  byval sdsize as integer ) as EMIT_NODE ptr

declare function	emitPOP				( byval svreg as IRVREG ptr ) as EMIT_NODE ptr

declare function	emitMEMMOVE			( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr, _
			 					  		  byval bytes as integer ) as EMIT_NODE ptr

declare function	emitMEMSWAP			( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr, _
			 					  		  byval bytes as integer ) as EMIT_NODE ptr

declare function	emitMEMCLEAR		( byval dvreg as IRVREG ptr, _
			 					  		  byval svreg as IRVREG ptr, _
			 					  		  byval bytes as integer ) as EMIT_NODE ptr

declare function	emitSTKCLEAR		( byval bytes as integer, _
				  						  byval baseofs as integer ) as EMIT_NODE ptr

declare sub 		emitSECTION			( byval section as integer )

declare sub 		emitDATALABEL		( byval label as zstring ptr )

declare sub 		emitDATABEGIN		( byval lname as zstring ptr )

declare sub 		emitDATA			( byval litext as zstring ptr, _
										  byval litlen as integer, _
										  byval dtype as integer )

declare sub 		emitDATAW			( byval litext as wstring ptr, _
										  byval litlen as integer, _
										  byval dtype as integer )

declare sub 		emitDATAOFS			( byval sname as zstring ptr )

declare sub 		emitDATAEND			( )

declare sub 		emitVARINIBEGIN		( byval sym as FBSYMBOL ptr )

declare sub 		emitVARINIEND		( byval sym as FBSYMBOL ptr )

declare sub 		emitVARINIi			( byval dtype as integer, _
										  byval value as integer )

declare sub 		emitVARINIf			( byval dtype as integer, _
										  byval value as double )

declare sub 		emitVARINI64		( byval dtype as integer, _
										  byval value as longint )

declare sub 		emitVARINIOFS		( byval sname as zstring ptr )

declare sub 		emitVARINISTR		( byval s as zstring ptr )

declare sub 		emitVARINIWSTR		( byval s as zstring ptr )

declare sub 		emitVARINIPAD		( byval bytes as integer )

declare sub 		hWriteStr			( byval addtab as integer, _
										  byval s as zstring ptr )

declare sub 		emitReset			( )

declare sub 		emitFlush			( )

#define emitGetLocalOfs(p) p->proc.ext->stk.localofs

#define emitSetLocalOfs(p,ofs) p->proc.ext->stk.localofs = ofs

''::::
#define EMIT_REGSETUSED(c,r) emit.regUsedTB(c) or= (1 shl r)
#define EMIT_REGISUSED(c,r) ((emit.regUsedTB(c) and (1 shl r)) <> 0)
#define EMIT_REGCLEARALL(c) emit.regUsedTB(c) = 0
#define EMIT_REGTRASHALL(c) emit.regUsedTB(c) = -1

''
'' inter-module globals
''
extern emit as EMITCTX

extern emit_opfTB(0 to EMIT_MAXOPS-1) as any ptr

#endif '' __EMIT_BI__
