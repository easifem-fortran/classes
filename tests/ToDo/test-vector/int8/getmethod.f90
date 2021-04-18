program main
	use globaldata
	use io
	use int8vector_class
	implicit none

	!test-1
	! BLOCK
	! 	type( int8vector_ ) :: obj
	! 	obj = Int8Vector( INT( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], int8 ) )
	! 	call obj % display( )
	! END BLOCK

	!test-2
	! BLOCK
	! 	type( int8vector_ ) :: obj
	! 	integer( int8 ), allocatable :: z( : )
	! 	obj = Int8Vector( INT( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], int8 ) )
	! 	z = ArrayValues( obj, TypeInt )
	! 	obj = Int8Vector( z )
	! 	call obj % display( )
	! END BLOCK

	!test-3
	! BLOCK
	! 	type( int8vector_ ) :: obj, obj2
	! 	obj = Int8Vector( INT( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], int8 ) )
	! 	obj2 = ArrayValues( obj, TypeInt8Vector )
	! 	call obj2 % display( )
	! END BLOCK

	!test-4
	! BLOCK
	! 	type( int8vector_ ) :: obj
	! 	INTEGER( Int8 ), ALLOCATABLE :: z( : )
	! 	obj = Int8Vector( INT( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], int8 ) )
	! 	z = ArrayValues( obj, [1,2], TypeInt )
	! END BLOCK

	!test-5
	! BLOCK
	! 	type( int8vector_ ) :: obj, obj2
	! 	INTEGER( Int8 ), ALLOCATABLE :: z( : )
	! 	obj = Int8Vector( INT( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], int8 ) )
	! 	obj2 = ArrayValues( obj, [1,2], TypeInt8Vector )
	! 	call obj2 % display( )
	! 	z = ArrayValues( obj, 1, 10, 2, TypeInt8 )
	! 	write( *, * ) z
	! 	obj2 = ArrayValues( obj, 1, 10, 2, TypeInt8Vector )
	! 	call obj2 % display( )
	! END BLOCK

	! BLOCK
	! 	TYPE(int8vector_) :: obj( 3 )
	! 	INTEGER( Int8 ), ALLOCATABLE :: z( : )
	! 	obj( 1 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
	! 	obj( 2 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
	! 	obj( 3 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
	! 	z = ArrayValues( obj, TypeInt8 )
	! 	write( *, * ) z
	! END BLOCK

	! BLOCK
	! 	TYPE(int8vector_) :: obj( 3 )
	! 	INTEGER( Int8 ), ALLOCATABLE :: z( : )
	! 	obj( 1 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
	! 	obj( 2 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
	! 	obj( 3 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
	! 	z = ArrayValues( obj, [1,2,3], TypeInt8 )
	! 	write( *, * ) z
	! END BLOCK

	BLOCK
		TYPE(int8vector_) :: obj( 3 )
		INTEGER( Int8 ), ALLOCATABLE :: z( : )
		obj( 1 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
		obj( 2 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
		obj( 3 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
		z = ArrayValues( obj, 1, 10, 2, TypeInt8 )
		write( *, * ) z
	END BLOCK

	call equalline( )

	BLOCK
		TYPE(int8vector_) :: obj( 3 ), obj2
		obj( 1 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
		obj( 2 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
		obj( 3 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
		obj2 = ArrayValues( obj, TypeInt8Vector )
		CALL obj2 % Display( )
	END BLOCK

	call equalline( )

	BLOCK

		TYPE(int8vector_) :: obj( 4 ), obj2
		obj( 1 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
		obj( 2 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
		obj( 3 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
		obj( 4 ) = Int8Vector( [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] )
		obj2 = ArrayValues( obj( 1:4:2 ), TypeInt8Vector )
		CALL obj2 % Display( )
	END BLOCK

end program main