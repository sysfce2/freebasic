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


'' generic double-linked list
''
'' chng: jan/2005 written [v1ctor]
''

option explicit
option escape

const NULL = 0

#include once "inc\list.bi"


'':::::
function listNew( byval list as TLIST ptr, _
				  byval nodes as integer, _
				  byval nodelen as integer, _
				  byval doclear as integer, _
				  byval relink as integer _
				) as integer

	'' fill ctrl struct
	list->tbhead 	= NULL
	list->tbtail 	= NULL
	list->nodes 	= 0
	list->nodelen	= nodelen + len( TLISTNODE )
	list->head		= NULL
	list->tail		= NULL
	list->clear		= doclear

	'' allocate the initial pool
	function = listAllocTB( list, nodes, relink )

end function

'':::::
function listFree( byval list as TLIST ptr ) as integer
    dim as TLISTTB ptr tb, nxt

	'' for each pool, free the mem block and the pool ctrl struct
	tb = list->tbhead
	do while( tb <> NULL )
		nxt = tb->next
		deallocate( tb->nodetb )
		deallocate( tb )
		tb = nxt
	loop

	list->tbhead 	= NULL
	list->tbtail 	= NULL
	list->nodes		= 0

	function = TRUE

end function

'':::::
function listAllocTB( byval list as TLIST ptr, _
					  byval nodes as integer, _
					  byval relink as integer = TRUE _
					) as integer static

	dim as TLISTNODE ptr nodetb, node, prv
	dim as TLISTTB ptr tb
	dim as integer i

	function = FALSE

	if( nodes <= 1 ) then
		exit function
	end if

	'' allocate the pool
	if( list->clear ) then
		nodetb = callocate( nodes * list->nodelen )
	else
		nodetb = allocate( nodes * list->nodelen )
	end if
	if( nodetb = NULL ) then
		exit function
	end if

	'' and the pool ctrl struct
	tb = allocate( len( TLISTTB ) )
	if( tb = NULL ) then
		deallocate( nodetb )
		exit function
	end if

	'' add the ctrl struct to pool list
	if( list->tbhead = NULL ) then
		list->tbhead = tb
	end if
	if( list->tbtail <> NULL ) then
		list->tbtail->next = tb
	end if
	list->tbtail = tb

	tb->next 	= NULL
	tb->nodetb 	= nodetb
	tb->nodes 	= nodes

	'' add new nodes to the free list
	list->fhead = nodetb
	list->nodes += nodes

	''
	if( relink ) then
		prv = NULL
		node = list->fhead

		for i = 1 to nodes-1
			node->prev	= prv
			node->next	= cast( TLISTNODE ptr, cast( byte ptr, node ) + list->nodelen )

			prv 	   	= node
			node 		= node->next
		next

		node->prev = prv
		node->next = NULL
	end if

	''
	function = TRUE

end function

'':::::
function listNewNode( byval list as TLIST ptr ) as any ptr static
	dim as TLISTNODE ptr node, tail

	'' alloc new node list if there are no free nodes
	if( list->fhead = NULL ) Then
		listAllocTB( list, cunsg(list->nodes) \ 4 )
	end if

	'' take from free list
	node = list->fhead
	list->fhead = node->next

	'' add to used list
	tail = list->tail
	list->tail = node
	if( tail <> NULL ) then
		tail->next = node
	else
		list->head = node
	end If

	node->prev	= tail
	node->next	= NULL

	''
	function = cast( byte ptr, node ) + len( TLISTNODE )

end function

'':::::
sub listDelNode( byval list as TLIST ptr, _
				 byval node_ as any ptr ) static

	dim as TLISTNODE ptr node, prv, nxt

	if( node_ = NULL ) then
		exit sub
	end if

	node = cast( TLISTNODE ptr, cast( byte ptr, node_ ) - len( TLISTNODE ) )

	'' remove from used list
	prv = node->prev
	nxt = node->next
	if( prv <> NULL ) then
		prv->next = nxt
	else
		list->head = nxt
	end If

	if( nxt <> NULL ) then
		nxt->prev = prv
	else
		list->tail = prv
	end If

	'' add to free list
	node->next = list->fhead
	list->fhead = node

	'' node can contain strings descriptors, so, erase it..
	if( list->clear ) then
		clear( byval node_, 0, list->nodelen - len( TLISTNODE ) )
	end if

end sub

'':::::
function listGetHead( byval list as TLIST ptr ) as any ptr

	if( list->head = NULL ) then
		function = NULL
	else
		function = cast( byte ptr, list->head ) + len( TLISTNODE )
	end if

end function

'':::::
function listGetTail( byval list as TLIST ptr ) as any ptr

	if( list->tail = NULL ) then
		function = NULL
	else
		function = cast( byte ptr, list->tail ) + len( TLISTNODE )
	end if

end function

'':::::
function listGetPrev( byval node as any ptr ) as any ptr
    dim as TLISTNODE ptr prev

#ifdef DEBUG
	if( node = NULL ) then
		return NULL
	end if
#endif

	 prev = cast( TLISTNODE ptr, _
				  cast( byte ptr, node ) - len( TLISTNODE ) )->prev

	if( prev = NULL ) then
		function = NULL
	else
		function = cast( byte ptr, prev ) + len( TLISTNODE )
	end if

end function

'':::::
function listGetNext( byval node as any ptr ) as any ptr
    dim as TLISTNODE ptr nxt

#ifdef DEBUG
	if( node = NULL ) then
		return NULL
	end if
#endif

	nxt = cast( TLISTNODE ptr, _
				cast( byte ptr, node ) - len( TLISTNODE ) )->next

	if( nxt = NULL ) then
		function = NULL
	else
		function = cast( byte ptr, nxt ) + len( TLISTNODE )
	end if

end function

