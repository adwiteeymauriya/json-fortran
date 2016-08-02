!*****************************************************************************************
!>
! Module for the first unit test.
!
!# HISTORY
!  * Izaak Beekman : 2/18/2015 : Created (refactoried original json_example.f90 file)

module jf_test_1_mod

    use json_module
    use, intrinsic :: iso_fortran_env , only: error_unit, output_unit, wp => real64

    implicit none

    character(len=*),parameter :: dir = '../files/inputs/'    !! working directory
    character(len=*),parameter :: filename1 = 'test1.json'    !! file to read
    logical :: namelist_style !! for printing JSON variable paths

contains

    subroutine test_1(error_cnt)

    !! Read a sample JSON file and retrieve some data from it

    implicit none

    type(json_file) :: json       !! the JSON structure read from the file
    type(json_value),pointer :: p !! a pointer for low-level manipulations
    type(json_core) :: core       !! factory for manipulating `json_value` pointers
    integer,intent(out) :: error_cnt
    integer :: ival
    character(kind=json_CK,len=:),allocatable :: cval
    real(wp) :: rval
    logical :: found

    error_cnt = 0
    call json%initialize()
    if (json%failed()) then
      call json%print_error_message(error_unit)
      error_cnt = error_cnt + 1
    end if

    write(error_unit,'(A)') ''
    write(error_unit,'(A)') '================================='
    write(error_unit,'(A)') '   TEST 1'
    write(error_unit,'(A)') '================================='
    write(error_unit,'(A)') ''

    ! parse the json file:
    write(error_unit,'(A)') ''
    write(error_unit,'(A)') 'parsing file '//dir//filename1

    call json%load_file(filename = dir//filename1)

    if (json%failed()) then    !if there was an error reading the file

      call json%print_error_message(error_unit)
      error_cnt = error_cnt + 1

    else

      ! print the parsed data to the console
      write(error_unit,'(A)') ''
      write(error_unit,'(A)') 'printing the file...'
      call json%print_file()
      if (json%failed()) then
        call json%print_error_message(error_unit)
        error_cnt = error_cnt + 1
      end if

      ! -------------------------
      ! print each variable:

      call core%initialize()
      call json%get(p) ! get root

      namelist_style = .true.
      write(error_unit,'(A)') ''
      write(error_unit,'(A)') 'printing each variable [namelist style]'
      write(error_unit,'(A)') ''
      call core%initialize(unescape_strings=.false.)
      call core%traverse(p,print_json_variable)

      namelist_style = .false.
      write(error_unit,'(A)') ''
      write(error_unit,'(A)') 'printing each variable [JSON style]'
      write(error_unit,'(A)') ''
      call core%initialize(unescape_strings=.true.)
      call core%traverse(p,print_json_variable)

      ! -------------------------

      ! extract data from the parsed value
      write(error_unit,'(A)') ''
      write(error_unit,'(A)') 'get some data from the file...'

      write(error_unit,'(A)') ''
      call json%get('version.svn', ival)
      if (json%failed()) then
        call json%print_error_message(error_unit)
        error_cnt = error_cnt + 1
      else
        write(error_unit,'(A,I5)') 'version.svn = ',ival
      end if

      write(error_unit,'(A)') ''
      call json%get('data(1).array(2)', cval)
      if (json%failed()) then
        call json%print_error_message(error_unit)
        error_cnt = error_cnt + 1
      else
        write(error_unit,'(A)') 'data(1).array(2) = '//trim(cval)
      end if

      write(error_unit,'(A)') ''
      call json%get('files(1)', cval)
      if (json%failed()) then
        call json%print_error_message(error_unit)
        error_cnt = error_cnt + 1
      else
        write(error_unit,'(A)') 'files(1) = '//trim(cval)
      end if

      write(error_unit,'(A)') ''
      call json%get('files(2)', cval)
      if (json%failed()) then
        call json%print_error_message(error_unit)
        error_cnt = error_cnt + 1
      else
        write(error_unit,'(A)') 'files(2) = '//trim(cval)
      end if

      write(error_unit,'(A)') ''
      call json%get('files(3)', cval)
      if (json%failed()) then
        call json%print_error_message(error_unit)
        error_cnt = error_cnt + 1
      else
        write(error_unit,'(A)') 'files(3) = '//trim(cval)
      end if

      write(error_unit,'(A)') ''
      call json%get('data(2).real', rval)
      if (json%failed()) then
        call json%print_error_message(error_unit)
        error_cnt = error_cnt + 1
      else
        write(error_unit,'(A,E30.16)') 'data(2).real = ',rval
      end if

      write(error_unit,'(A)') ''
      call json%get('files[4]', cval)      !has hex characters
      if (json%failed()) then
        call json%print_error_message(error_unit)
        error_cnt = error_cnt + 1
      else
        write(error_unit,'(A)') 'files[4] = '//trim(cval)
      end if

      write(error_unit,'(A)') ''
      call json%get('files[5]', cval)      !string with spaces and no escape characters
      if (json%failed()) then
        call json%print_error_message(error_unit)
        error_cnt = error_cnt + 1
      else
        write(error_unit,'(A)') 'files[5] = '//trim(cval)
      end if

      !
      ! Test of values that aren't there:
      ! Note: when using the "found" output, the exceptions are cleared automatically.
      !

      write(error_unit,'(A)') ''
      call json%get('files[10]', cval, found)      !value that isn't there
      if (.not. found) then
        write(error_unit,'(A)') 'files[10] not in file.'
      else
        write(error_unit,'(1x,A)') 'files[10] = '//trim(cval)
        error_cnt = error_cnt + 1
      end if

      write(error_unit,'(A)') ''
      call json%get('version.blah', ival, found)      !value that isn't there
      if (.not. found) then
        write(error_unit,'(A)') 'version.blah not in file.'
      else
        write(error_unit,'(A)') 'version.blah = ',ival
        error_cnt = error_cnt + 1
      end if

      write(error_unit,'(A)') ''
      write(error_unit,'(A)') ' Test removing data from the json structure:'

      call json%get('files', p)         !in the middle of a list
      if (json%failed()) then
          call json%print_error_message(error_unit)
          error_cnt = error_cnt + 1
      else
          call core%initialize()
          call core%remove(p)
          if (core%failed()) then
            call core%print_error_message(error_unit)
            error_cnt = error_cnt + 1
          end if
      end if

      call json%get('data(1).array', p)   !at the end of a list
      if (json%failed()) then
          call json%print_error_message(error_unit)
          error_cnt = error_cnt + 1
      else
          call core%initialize()
          call core%remove(p)
          if (core%failed()) then
            call core%print_error_message(error_unit)
            error_cnt = error_cnt + 1
          end if
      end if

      call json%get('data(2).number', p)  !at the beginning of a list
      if (json%failed()) then
          call json%print_error_message(error_unit)
          error_cnt = error_cnt + 1
      else
          call core%initialize()
          call core%remove(p)
          if (core%failed()) then
            call core%print_error_message(error_unit)
            error_cnt = error_cnt + 1
          end if
      end if

      write(error_unit,'(A)') ''
      write(error_unit,'(A)') 'printing the modified structure...'
      call json%print_file()
      if (json%failed()) then
        call json%print_error_message(error_unit)
        error_cnt = error_cnt + 1
      end if

      write(error_unit,'(A)') ''
      write(error_unit,'(A)') ' Test replacing data from the json structure:'

      call json%get('data(1)', p)
      if (json%failed()) then
          call json%print_error_message(error_unit)
          error_cnt = error_cnt + 1
      else
          call core%initialize()
          call core%update(p,'name','Cuthbert',found)
          if (core%failed()) then
            call core%print_error_message(error_unit)
            error_cnt = error_cnt + 1
          end if
      end if

      !call json%get('data(2)', p)
      !call json%update(p,'real',[1.0_wp, 2.0_wp, 3.0_wp],found)   !don't have one like this yet...

      !use the json_file procedure to update a variable:
      call json%update('version.svn',999,found)
      if (json%failed()) then
        call json%print_error_message(error_unit)
        error_cnt = error_cnt + 1
      end if

      write(error_unit,'(A)') ''
      write(error_unit,'(A)') 'printing the modified structure...'
      call json%print_file()
      if (json%failed()) then
        call json%print_error_message(error_unit)
        error_cnt = error_cnt + 1
      end if

      write(error_unit,'(A)') ''
      write(error_unit,'(A)') 'printing the modified structure (compact mode)...'
      call json%initialize(no_whitespace=.true.)
      call json%print_file()
      if (json%failed()) then
        call json%print_error_message(error_unit)
        error_cnt = error_cnt + 1
      end if

    end if

    ! clean up
    write(error_unit,'(A)') ''
    write(error_unit,'(A)') 'destroy...'
    call json%destroy()
    if (json%failed()) then
      call json%print_error_message(error_unit)
      error_cnt = error_cnt + 1
    end if

    end subroutine test_1

    subroutine print_json_variable(json,p,finished)

    !! A `traverse` routine for printing out all
    !! the variables in a JSON structure.

    implicit none

    class(json_core),intent(inout)      :: json
    type(json_value),pointer,intent(in) :: p
    logical(json_LK),intent(out)        :: finished  !! set true to stop traversing

    character(kind=json_CK,len=:),allocatable :: path !! path to the variable
    logical(json_LK) :: found !! error flag
    type(json_value),pointer :: child !! variable's first child
    character(kind=json_CK,len=:),allocatable :: value !! variable value as a string
    integer(json_IK) :: var_type !! JSON variable type

    call json%get_child(p,child)
    finished = .false.

    !only print the leafs:
    if (.not. associated(child)) then
        if (namelist_style) then
            call json%get_path(p,path,found,&
                               use_alt_array_tokens=.true.,&
                               path_sep=json_CK_'%')  ! fortran-style
        else
            call json%get_path(p,path,found)  ! JSON-style
        end if
        if (found) then

            call json%info(p,var_type=var_type)
            select case (var_type)
            case (json_array)
                !an empty array
                value = json_CK_'()'
            case (json_object)
                !an empty object
                value = json_CK_'{}'
            case default
                ! get the value as a string
                ! [assumes strict_type_checking=false]
                ! note: strings are returned escaped without quotes
                call json%get(p,value)
            end select

            !check for errors:
            if (json%failed()) then
                finished = .true.
            else
                write(output_unit,'(A)') path//json_CK_' = '//value
            end if

        else
            finished = .true.
        end if
    end if

    end subroutine print_json_variable

end module jf_test_1_mod
!*****************************************************************************************

!*****************************************************************************************
program jf_test_1

    !! First unit test.

    use jf_test_1_mod , only: test_1
    implicit none
    integer :: n_errors
    n_errors = 0
    call test_1(n_errors)
    if (n_errors /= 0) stop 1

end program jf_test_1
!*****************************************************************************************
