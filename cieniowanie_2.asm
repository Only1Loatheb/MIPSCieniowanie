#Cieniowanie trójk¹ta (zadane w konsoli wspó³rzêdne trzech wierzcho³ków i ich kolory) wynik w BMP
#obrazek moze ju¿ istnieæ lub byæ generowany przez program
.data
.align 2
size:		.word 0	# rozmiar pliku bmp
width:		.word 0	# szerokosc pliku bmp
height:		.word 0	# wysokosc pliku bmp
off:		.word 0	# offset - poczatek adres bitow w tablicy pikseli
temp:		.word 0	# bufor na czesci naglowka
begin:		.word 0	# adres poczatku linijki
memory:		.word 0 # memory descriptor
# Triangle Coords
x0:		.word 0
y0:		.word 0
x1:		.word 99	
y1:		.word 33
x2:		.word 0	# x punktu pomocniczyego
y2:		.word 0	# y punktu pomocniczyego
x3:		.word 66	
y3:		.word 99	
# Color Coords	       #R|G|B|0
color0:		.word 0xffff0000	
color1:		.word 0x00ffff00
color3:		.word 0xff00ff00
# Backed up registers
v1_2dy_bres2:	.word 0
a3_2dx_bres1:	.word 0
t0_d_bres1:	.word 0
# Proporties
bitmap_begin:	.word 0
bitmap_width:	.word 0
rotate_if_zero: .word 1
padding:	.byte 0	# iloœæ padding
# Strings
input_file:	.asciiz	"in2.bmp"
output_file:	.asciiz "out.bmp"
m_in_file_err:	.asciiz "Input file (in.bmp) not opened\n"
m_out_file_err:	.asciiz "Output file (out.bmp) not created\n"
m_out_save_err: .asciiz "Output file (out.bmp) not saved\n"
m_case_not_implemented: .asciiz "m_case_not_implemented\n"
m_enter_x0:	.asciiz "Podaj wspolrzedna X pierwszego punktu z przedzialu 0 - "
m_enter_y0:	.asciiz "Podaj wspolrzedna Y pierwszego punktu z przedzialu 0 - "
m_enter_x1:	.asciiz "Podaj wspolrzedna X drugiego punktu z przedzialu 0 - "
m_enter_y1:	.asciiz "Podaj wspolrzedna Y drugiego punktu z przedzialu 0 - "
m_enter_x3:	.asciiz "Podaj wspolrzedna X trzeciego punktu z przedzialu 0 - "
m_enter_y3:	.asciiz "Podaj wspolrzedna Y trzeciego punktu z przedzialu 0 - "
m_enter_red0:	.asciiz "Podaj kolor CZERWONY pierwszego punktu z przedzialu 0 - 255\n"
m_enter_green0:	.asciiz "Podaj kolor ZIELONY pierwszego punktu z przedzialu 0 - 255\n"
m_enter_blue0:	.asciiz "Podaj kolor NIEBIESKI pierwszego punktu z przedzialu 0 - 255\n"
m_enter_red1:	.asciiz "Podaj kolor CZERWONY drugiego punktu z przedzialu 0 - 255\n"
m_enter_green1:	.asciiz "Podaj kolor ZIELONY drugiego punktu z przedzialu 0 - 255\n"
m_enter_blue1:	.asciiz "Podaj kolor NIEBIESKI drugiego punktu z przedzialu 0 - 255\n"
m_enter_red3:	.asciiz "Podaj kolor CZERWONY trzeciego punktu z przedzialu 0 - 255\n"
m_enter_green3:	.asciiz "Podaj kolor ZIELONY trzeciego punktu z przedzialu 0 - 255\n"
m_enter_blue3:	.asciiz "Podaj kolor NIEBIESKI trzeciego punktu z przedzialu 0 - 255\n"

.text
.globl main
main:
read_in_file:
open_in_file:
	la $a0, input_file # wczytanie nazwy pliku do otwarcia
	li $a1, 0	# flagi otwarcia
	li $a2, 0	# tryb otwarcia
	li $v0, 13	# ustawienie syscall na otwieranie pliku
	syscall		# otwarcie pliku, zostawienie w $v0 jego deskryptora
	
	move $t0, $v0	# przekopiowanie deskryptora do rejestru t0	
	bltz $t0, input_file_err	# przeskocz do blad_plik jesli wczytywanie sie nie powiodlo
read_in_file_header_MB:	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, temp	# wskazanie bufora wczytywania
	li $a2, 2	# ustawienie odczytu 2 pierwszych bajtow zawieraj¹ "BM"
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# odczytanie z pliku
	
	bltz $v0, input_file_err
read_in_file_size:	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, size	# wskazanie zmiennej do przechowywania wczytanych danych
	li $a2, 4	# ustawienie odczytu 4 bajtow
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# wczytanie rozmiaru pliku do size
	
	bltz $v0, input_file_err
read_in_file_header:	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, temp	# wskazanie bufora wczytywania
	li $a2, 4	# ustawienie odczytu 4 bajtow zarezerwowanych
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# przejscie o 4 bajty od przodu
	
	bltz $v0, input_file_err
read_in_file_offset:	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, off	# wskazanie zmiennej do przechowywania offsetu
	li $a2, 4	# ustawienie odczytu 4 bajtow offsetu
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# wczytanie offsetu do off
	
	bltz $v0, input_file_err
read_in_file_info_size:	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, temp	# wskazanie bufora wczytywania
	li $a2, 4	# ustawienie odczytu 4 bajtow - wielkosci naglowka informacyjnego
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# przejscie o 4 bajty od przodu
	
	bltz $v0, input_file_err
read_in_file_width:	
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, width	# wskazanie zmiennej do przechowywania szerokosci
	li $a2, 4	# ustawienie odczytu 4 bajtow - szerokosci
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# wczytanie szerokosci bitmapy
	
	bltz $v0, input_file_err
read_in_file_height:
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, height	# wskazanie zmiennej do przechowywania wysokosci
	li $a2, 4	# ustawienie odczytu 4 bajtow - wysokosci
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		# wczytanie wysokosci bitmapy
	
	bltz $v0, input_file_err
close_in_file:
	move $a0, $t0	# przekopiowanie deskryptora pliku do a0
	li $v0, 16	# ustawienie syscall na zamkniecie pliku
	syscall		# zamkniecie pliku o deskryptorze w a0
alocate_memory:
	li $v0, 9	# ustawienie syscall na alokacje pamieci
	lw $a0, size	# przekopiowanie rozmiaru pliku do rejestru t7
	syscall		# zaalokowanie pamieci o rozmiarze pliku
	move $t1, $v0	# przekopiowanie adesu zaalokowanej pamieci do rejestru t1
	sw $t1, memory
copy_in_file_to_memory:
reopen_in_file:
	la $a0, input_file	# wczytanie nazwy pliku do otwarcia
	li $a1, 0	# flagi otwarcia
	li $a2, 0	# tryb otwarcia
	li $v0, 13	# ustawienie syscall na otwieranie pliku
	syscall		# otwarcie pliku, zostawienie w $v0 jego deskryptora
	
	move $t0, $v0	# przekopiowanie deskryptora do rejestru t0
	bltz $t0, input_file_err	# przeskocz do blad_plik jesli wczytywanie sie nie powiodlo
read_in_file_data_to_memory:	
	lw $t7, size
	move $a0, $t0	# przekopiowanie deskryptora 
	la $a1, ($t1)	# wskazanie wczesniej zaalokowanej pamieci jako miejsca do wczytania
	la $a2, ($t7)	# ustawienie odczytu tylu bajtow ile ma plik
	li $v0, 14	# ustawienie syscall na odczyt z pliku
	syscall		
	
	bltz $v0, input_file_err
reclose_in_file:
	move $a0, $t0	# przekopiowanie deskryptora 
	li $v0, 16	# ustawienie syscall na zamkniecie pliku
	syscall		# zamkniecie pliku o deskryptorze w a0

# $zero 0
# $at
# $v0 temp
# $v1 2dy bres2					# row red step
# $a0 // current R bres1 8.16
# $a1 // current G bres1 8.16
# $a2 curent in row adres
# $a3 2dx bres1					# row green step
# $t0 d bres1					# row blue step
# $t1 // current B bres1 8.16
# $t2 yi bres1 bres2
# $t3 current bres1
# $t4 last bres1 
# $t5 current bres2 
# $t6 // current R bres2 8.16
# $t7 xi bres2
# $s0 temp in inner interpolation 
# $s1 >> row red current 8.16
# $s2 // current G bres2 8.16
# $s3 2dx bres1
# $s4 2dy bres1
# $s5 // current B bres2 8.16
# $s6 xi bres1
# $s7 >> row green current 8.16
# $t8 >> row blue current 8.16
# $t9 d bres2
# $k0 // red step bres1  8.16
# $k1 // red step bres2 8.16
# $gp // green step bres1 8.16
# $sp // green step bres2 8.16
# $fp // blue step bres1 8.16
# $ra // blue step bres2 8.16

load_adreses:
	lw $a0, off		# zaladowanie offsetu do rejestru a0
	addu $t1, $t1, $a0	# przesuniecie na poczatek mapy pikseli
	sw $t1, bitmap_begin
	lw $t2, width	# zaladowanie szerokosci do rejestru t2
	andi $a0, $t2, 0x3	# reszty dzielenie przez 4
	addu $v0, $t2, $t2
	addu $t2, $t2, $v0
	addu $t2, $t2, $a0
	sw $t2, bitmap_width
	sw $a0, padding		#zapisz liczbe b paddingu w linni 

get_coords: #adres := x * 3 + y * $t2 + $t1
	b draw_triangle # comment this line to enter all coordinates and colors runtime  <------------------- 
	lw $s0, width
	addiu $s0, $s0, -1
	
	lw $s1, height
	addiu $s1, $s1, -1
get_x0:
	li $v0, 4
	la $a0, m_enter_x0
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 11
	li $a0, '\n' 
	syscall
	 
	li $v0, 5
	syscall
	
	bltz $v0, get_x0
	bgt $v0, $s0, get_x0
	sw $v0, x0
get_y0: 
	li $v0, 4
	la $a0, m_enter_y0
	syscall
	
	li $v0, 1
	move $a0, $s1
	syscall

	li $v0, 11
	li $a0, '\n' 
	syscall
	
	li $v0, 5
	syscall
	
	bltz $v0, get_y0
	bgt $v0, $s1, get_y0
	sw $v0, y0
get_x1:
	li $v0, 4
	la $a0, m_enter_x1
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 11
	li $a0, '\n' 
	syscall
	 
	li $v0, 5
	syscall
	
	bltz $v0, get_x1
	bgt $v0, $s0, get_x1
	sw $v0, x1
get_y1: 
	li $v0, 4
	la $a0, m_enter_y1
	syscall
	
	li $v0, 1
	move $a0, $s1
	syscall

	li $v0, 11
	li $a0, '\n' 
	syscall
	
	li $v0, 5
	syscall
	
	bltz $v0, get_y1
	bgt $v0, $s1, get_y1
	sw $v0, y1
get_x3:
	li $v0, 4
	la $a0, m_enter_x3
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 11
	li $a0, '\n' 
	syscall
	 
	li $v0, 5
	syscall
	
	bltz $v0, get_x3
	bgt $v0, $s0, get_x3
	sw $v0, x3
get_y3: 
	li $v0, 4
	la $a0, m_enter_y3
	syscall
	
	li $v0, 1
	move $a0, $s1
	syscall

	li $v0, 11
	li $a0, '\n' 
	syscall
	
	li $v0, 5
	syscall
	
	bltz $v0, get_y3
	bgt $v0, $s1, get_y3
	sw $v0, y3
get_red0:
	li $v0, 4 # print string
	la $a0, m_enter_red0
	syscall
	
	li $v0, 5 # read int 
	syscall
	
	bltz $v0, get_red0
	bgt $v0, 0xff, get_red0
	sll $s0, $v0, 16 # 0|R|0|0
get_green0:
	li $v0, 4 # print string
	la $a0, m_enter_green0
	syscall
	
	li $v0, 5 # read int 
	syscall
	
	bltz $v0, get_green0
	bgt $v0, 0xff, get_green0
	sll $v0, $v0, 8
	or $s0, $s0, $v0 # 0|R|G|0
get_blue0:
	li $v0, 4 # print string
	la $a0, m_enter_blue0
	syscall
	
	li $v0, 5 # read int 
	syscall
	
	bltz $v0, get_blue0
	bgt $v0, 0xff, get_blue0
	or $s0, $s0, $v0 # 0|R|G|B
	sll $s0, $s0, 8
	sw $s0, color0
get_red1:
	li $v0, 4 # print string
	la $a0, m_enter_red1
	syscall
	
	li $v0, 5 # read int 
	syscall
	
	bltz $v0, get_red1
	bgt $v0, 0xff, get_red1
	sll $s0, $v0, 16 # 0|R|0|0
get_green1:
	li $v0, 4 # print string
	la $a0, m_enter_green1
	syscall
	
	li $v0, 5 # read int 
	syscall
	
	bltz $v0, get_green1
	bgt $v0, 0xff, get_green1
	sll $v0, $v0, 8
	or $s0, $s0, $v0
get_blue1:
	li $v0, 4 # print string
	la $a0, m_enter_blue1
	syscall
	
	li $v0, 5 # read int 
	syscall
	
	bltz $v0, get_blue1
	bgt $v0, 0xff, get_blue1
	or $s0, $s0, $v0
	sll $s0, $s0, 8
	sw $s0, color1
get_red3:
	li $v0, 4 # print string
	la $a0, m_enter_red3
	syscall
	
	li $v0, 5 # read int 
	syscall
	
	bltz $v0, get_red3
	bgt $v0, 0xff, get_red3
	sll $s0, $v0, 16 # 0|R|0|0
get_green3:
	li $v0, 4 # print string
	la $a0, m_enter_green3
	syscall
	
	li $v0, 5 # read int 
	syscall
	
	bltz $v0, get_green3
	bgt $v0, 0xff, get_green3
	sll $v0, $v0, 8
	or $s0, $s0, $v0
get_blue3:
	li $v0, 4 # print string
	la $a0, m_enter_blue3
	syscall
	
	li $v0, 5 # read int 
	syscall
	
	bltz $v0, get_blue3
	bgt $v0, 0xff, get_blue3
	or $s0, $s0, $v0
	sll $s0, $s0, 8
	sw $s0, color3
draw_triangle: #a0-2 s0-2
load_points:
	lw $a0, x0 #load poins
	lw $s0, y0
	lw $a1, x1
	lw $s1, y1
	lw $a2, x2 # x punktu pomocniczyego
	lw $s2, y2 # y punktu pomocniczyego
	lw $a3, x3
	lw $s3, y3
sort_points:
	bge $s1,$s0 p0_p1_sorted  
swap_a0_a1:	
	move $v0, $a0
	move $a0, $a1
	move $a1, $v0
swap_s0_s1:
	move $v0, $s0
	move $s0, $s1
	move $s1, $v0
	
	lw $v0, color0
	lw $v1, color1
	sw $v1, color0
	sw $v0, color1
p0_p1_sorted:
	bge $s3,$s0 p0_p3_sorted 
swap_a0_a3:	
	move $v0, $a3
	move $a3, $a0
	move $a0, $v0
swap_s0_s3:
	move $v0, $s3
	move $s3, $s0
	move $s0, $v0
	
	lw $v0, color0
	lw $v1, color3
	sw $v1, color0
	sw $v0, color3	
p0_p3_sorted:
	bge $s3,$s1 p1_p3_sorted
swap_a1_a3:	
	move $v0, $a3
	move $a3, $a1
	move $a1, $v0
swap_s1_s3:
	move $v0, $s3
	move $s3, $s1
	move $s1, $v0
	
	lw $v0, color1
	lw $v1, color3
	sw $v1, color1
	sw $v0, color3	
p1_p3_sorted:
create_supp_point:
	move $s2, $s1
	
	sub $v0, $a3, $a0 #(a3 - a0)
	sub $v1, $s2, $s0 #(s2 - s0)
	mul $v0, $v0, $v1 #(a3 - a0)*(s2 - s0)
	sub $v1, $s3, $s0 #(s3 - s0)
	
	div $v0, $v1		# (a3 - a0)*(s2 - s0)/(s3 - s0)
	mflo $v0		# przekopiowanie lo do v0
	add $a2, $v0, $a0	#(a3 - a0)*(s2 - s0)/(s3 - s0) +a0
save_p0_p1_p2_p3:
	sw $a0, x0
	sw $s0, y0
	sw $a1, x1
	sw $s1, y1
	sw $a2, x2 # x punktu pomocniczyego
	sw $s2, y2 # y punktu pomocniczyego
	sw $a3, x3
	sw $s3, y3
points_set:
color_interpolation_prolog:
red_bres1_interpolation:
	lbu $a0, color0 + 3 # $a0 == y0 == begin().R() 
	lbu $a1, color1 + 3 # $a1 == y1 == end().R()
	sub $a1, $a1, $a0  # $a1 == (y1 - y0)
	sll $a1, $a1, 16 # $a1 == (y1 - y0) # 8.16
	sub $v0, $s1, $s0 # $v0 == (x1 - x0) 
	div $a1, $v0		# red step == (y1 - y0)/(x1 - x0)
	mflo $k0		# $k0 == red step bres1 # 8.16
green_bres1_interpolation:
	lbu $a0, color0 + 2 # $a0 == y0 == begin().G() 
	lbu $a1, color1 + 2 # $a1 == y1 == end().G()
	sub $a1, $a1, $a0 # $a1 == (y1 - y0)
	sll $a1, $a1, 16 # $a1 == (y1 - y0) # 8.16
	div $a1, $v0 # green step == (y1 - y0)/(x1 - x0) 
	mflo $gp	# $gp == green step bres 1# 8.16
blue_bres1_interpolation:
	lbu $a0, color0 + 1 # $a0 == y0 == begin().B() 
	lbu $a1, color1 + 1 # $a1 == y1 == end().B()
	sub $a1, $a1, $a0  # $a1 == (y1 - y0)
	sll $a1, $a1, 16 # $a1 == (y1 - y0) # 8.16
	div $a1, $v0	# blue step == (y1 - y0)/(x1 - x0) 
	mflo $fp	# fp == blue step bres1 # 8.16
red_bres2_interpolation:
	lbu $a0, color0 + 3 # $a0 == y0 == begin().R() 
	lbu $a1, color3 + 3 # $a1 == y1 == end().R()
	sub $a1, $a1, $a0 # $a1 == (y1 - y0)
	sll $a1, $a1, 16 # $a1 == (y1 - y0) # 8.16
	sub $v0, $s3, $s0 # $v0 == (x1 - x0)
	div $a1, $v0	# red step == (y1 - y0)/(x1 - x0)
	mflo $k1	# == red step bres1 # 8.16
green_bres2_interpolation:
	lbu $a0, color0 + 2 # $a0 == y0 == begin().G() 
	lbu $a1, color3 + 2 # $a1 == y1 == end().G()
	sub $a1, $a1, $a0  # $a1 == (y1 - y0)
	sll $a1, $a1, 16 # $a1 == (y1 - y0) # 8.16
	div $a1, $v0	# (y1 - y0)/(x1 - x0)
	mflo $sp	# sp == green step bres2 # 8.16
blue_bres2_interpolation:
	lbu $a0, color0 + 1 # $a0 == y0 == begin().B() 
	lbu $a1, color3 + 1 # $a1 == y1 == end().B()
	sub $a1, $a1, $a0  # $a1 == (y1 - y0)
	sll $a1, $a1, 16 # $a1 == (y1 - y0) # 8.16
	div $a1, $v0	# (y1 - y0)/(x1 - x0)
	mflo $ra	#ra == blue step bres2 # 8.16
reload_points_coords:	
	lw $a0, x0 #load poins
	lw $s0, y0
	lw $a1, x1
	lw $s1, y1
	lw $a2, x2 # x punktu pomocniczyego
	lw $s2, y2 # y punktu pomocniczyego
	lw $a3, x3
	lw $s3, y3
sort_p1_p2:
	bge $a2,$a1 p1_p2_sorted
swap_a1_a2:	
	move $v0, $a2
	move $a2, $a1
	move $a1, $v0
swap_s1_s2:
	move $v0, $s2
	move $s2, $s1
	move $s1, $v0
swap_colors:	
	move $v0, $k0
	move $k0, $k1
	move $k1, $v0

	move $v0, $gp
	move $gp, $sp
	move $sp, $v0
	
	move $v0, $fp
	move $fp, $ra
	move $ra, $v0
	
	sw $a1, x1
	sw $s1, y1
	sw $a2, x2 # x punktu pomocniczyego
	sw $s2, y2 # y punktu pomocniczyego
		
	sw $zero, rotate_if_zero
p1_p2_sorted:
	beq $s0, $s1, other_half_of_triangle #do we need to draw anything at the bottom
bres_prolog: #s3-5 t4-5 rysujemy zawsze W strone dodatniego y
bres_1_begin_adres:
	addu $v0, $a0, $a0
	addu $v0, $v0, $a0
	mul $v1, $s0, $t2
	addu $v0, $v0, $v1
	addu $t3, $v0, $t1 # $t3 == bres 1 begin
bres_1_end_adres:
	addu $v0, $a1, $a1
	addu $v0, $v0, $a1
	mul $v1, $s1, $t2
	addu $v0, $v0, $v1
	addu $t4, $v0, $t1
	sub $t4, $t4, $t2
	addu $t4, $t4, 3
bres_2_begin_adres:
	move $t5, $t3
#bres_2_end_adres: #no need because both lines simultaniosly
	#mul $v0, $a2, 3
	#mul $v1, $s2, $t2
	#addu $v0, $v0, $v1
	#addu $t6, $v0, $t1
bres_1_dx:
	li  $s6, 3		#s6 == xi == 3 
	sub $s3, $a1, $a0	#s3 == dx
	blt $a0, $a1, bres_1_dy
	li $s6, -3		#s6 == xi == -3
	sub $s3, $a0, $a1	#s3 == dx
bres_1_dy:
	sub $s4, $s1, $s0 	#s4 == dy
	#sub $s4, $s0, $s1 	#s4 == dy # dla drógiego trójk¹ta to co w komciach
bres_2_dx:
	li  $t7, 3		#t7 == xi == 3 
	sub $a3, $a2, $a0	#a3 == dx
	blt $a0, $a2, bres_2_dy
	li $t7, -3		#t7 == xi == -3
	sub $a3, $a0, $a2	#a3 == dx
bres_2_dy:
	sub $v1, $s2, $s0 	#v1 == dy
	#sub $v1, $s0, $s2 	#v1 == dy # dla drógiego trójk¹ta to co w komciach
bres_2_prolog_choice:	
bres_2_X_prolog:
	add $v0, $v1, $v1 #v0 == dy *2
	sub $t9, $v0, $a3 #t9 == d == 2dy - dx
bres_2_Y_prolog:
	bgt $a3, $v1, bres_2_prolog_addition
	add $v0, $a3, $a3 #v0 == dx *2
	sub $t9, $v0, $v1 #t9 == d == 2dx -dy
bres_2_prolog_addition:
	add $a3, $a3, $a3 #a3 == dx *2
	add $v1, $v1, $v1 #v4 == dy *2
bres_1_prolog_choice:
bres_1_X_prolog:
	add $v0, $s4, $s4 #s4 == dy *2
	sub $t0, $v0, $s3 #t0 == d == 2dy - dx
	bgt $s3, $s4, bres_1_prolog_addition
bres_1_Y_prolog:
	add $v0, $s3, $s3 #s3 == dx *2
	sub $t0, $v0, $s4 #t0 == d == 2dx -dy
bres_1_prolog_addition:
	add $s3, $s3, $s3 #s3 == dx *2
	add $s4, $s4, $s4 #s4 == dy *2
bres_1_axis_choice:
	lbu $a0, color0 + 3 # red0 
	lbu $a1, color0 + 2 # green0
	lbu $t1, color0 + 1 # blue0
	sb $a0, 2($t3) # red0 
	sb $a1, 1($t3) # green0
	sb $t1, 0($t3) # blue0
	sll $a0, $a0, 16 # red0 8.16
	sll $a1, $a1, 16  # green0 8.16
	sll $t1, $t1, 16 # blue0 8.16
	move $t6, $a0  # red0 
	move $s2, $a1 # green0 
	move $s5, $t1 # blue0
	
	ble $s3, $s4, bres_1_Y
bres_1_X:
	ble $a3, $v1, bres_1_X_2_Y # bres_2_axis_choice:
	b  bres_1_X_2_X
bres_1_Y:
	ble $a3, $v1, bres_1_Y_2_Y # bres_2_axis_choice:
bres_1_Y_2_X:
bresYX_2_X_loop:
	move $v0, $t9	#v0 == t0 == d
	add $t9, $t9, $v1 # d +=2dy
	add $t5, $t5, $t7 # x += xi # not safe for line triangle
	bltz $v0 bresYX_2_X_loop # d < 0 
	add $t5, $t5, $t2 #y +=yi  # dla drugiego trójk¹ta yi = - width
	sub $t9, $t9, $a3 #d -= 2dx
bresYX_1_Y_loop:
	move $v0, $t0 #v0 == t0 == d
	add $t0, $t0, $s3 # d +=2dx
	add $t3, $t3, $t2 #y += yi  # dla drugiego trójk¹ta yi = - width
	bltz $v0 bres_Y_X_draw
	add $t3, $t3, $s6 #x+=xi 
	sub $t0, $t0, $s4 #d -= 2dy
bres_Y_X_draw: 
	sw $v1, v1_2dy_bres2 #backing up registers
	sw $a3, a3_2dx_bres1
	sw $t0, t0_d_bres1

	addu $a0, $a0, $k0 # red bres 1 
	addu $a1, $a1, $gp # green bres 1
	addu $t1, $t1, $fp # blue bres 1
	addu $t6, $t6, $k1 # red bres 2
	addu $s2, $s2, $sp # green bres 2
	addu $s5, $s5, $ra # blue bres 2
	
	move $s1, $a0 # red current == red begin 
	move $s7, $a1 # green current == greem begin 
	move $t8, $t1 # blue current == blue begin
Y_X_interpolation:
	sub $v0, $t5, $t3 # $v0 == (x1 - x0)*3 

	sub $s0, $t6, $a0  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $v1		
	add $s0, $v1, $v1	
	add $v1, $v1, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s2, $a1  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $a3
	add $s0, $a3, $a3
	add $a3, $a3, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s5, $t1  # $a1 == (y1 - y0) 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $t0
	add $s0, $t0, $t0
	add $t0, $t0, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
		
	move $a2, $t3 # $a2 = begin()
Y_X_draw_loop:
	srl $v0, $s1, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 2($a2) # red
	srl $v0, $s7, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 1($a2) # green
	srl $v0, $t8, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, ($a2) # blue
	
	addiu $a2, $a2, 3 # ++i
	add $s1, $s1, $v1
	add $s7, $s7, $a3
	add $t8, $t8, $t0		
	ble $a2, $t5, Y_X_draw_loop
	
	lw $v1, v1_2dy_bres2
	lw $a3, a3_2dx_bres1
	lw $t0, t0_d_bres1
			
	blt $t3, $t4, bresYX_2_X_loop 
	b bres_1_2_end
bres_1_X_2_X:
bresXX_1_X_loop:
	move $v0, $t0	#v0 == t0 == d
	add $t0, $t0, $s4 # d +=2dy
	add $t3, $t3, $s6 # x += xi
	bltz $v0 bresXX_1_X_loop # d < 0 # not safe for line triangle
	add $t3, $t3, $t2 #y +=yi  # dla drugiego trójk¹ta yi = - width
	sub $t0, $t0, $s3 #d -= 2dx
bresXX_2_X_loop:
	move $v0, $t9	#v0 == t0 == d
	add $t9, $t9, $v1 # d +=2dy
	add $t5, $t5, $t7 # x += xi
	bltz $v0 bresXX_2_X_loop # d < 0 # not safe for line triangle
	add $t5, $t5, $t2 #y +=yi  # dla drugiego trójk¹ta yi = - width
	sub $t9, $t9, $a3 #d -= 2dx
bres_X_X_draw: 
	sw $v1, v1_2dy_bres2 #backing up registers
	sw $a3, a3_2dx_bres1
	sw $t0, t0_d_bres1

	addu $a0, $a0, $k0 # red bres 1 
	addu $a1, $a1, $gp # green bres 1
	addu $t1, $t1, $fp # blue bres 1
	addu $t6, $t6, $k1 # red bres 2
	addu $s2, $s2, $sp # green bres 2
	addu $s5, $s5, $ra # blue bres 2
	
	move $s1, $a0 # red current == red begin 
	move $s7, $a1 # green current == greem begin 
	move $t8, $t1 # blue current == blue begin
X_X_interpolation:
	sub $v0, $t5, $t3 # $v0 == (x1 - x0)*3 

	sub $s0, $t6, $a0  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $v1		
	add $s0, $v1, $v1	
	add $v1, $v1, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s2, $a1  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $a3
	add $s0, $a3, $a3
	add $a3, $a3, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s5, $t1  # $a1 == (y1 - y0) 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $t0
	add $s0, $t0, $t0
	add $t0, $t0, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
		
	move $a2, $t3 # $a2 = begin()
X_X_draw_loop:
	srl $v0, $s1, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 2($a2) # red
	srl $v0, $s7, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 1($a2) # green
	srl $v0, $t8, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, ($a2) # blue
	
	addiu $a2, $a2, 3 # ++i
	add $s1, $s1, $v1
	add $s7, $s7, $a3
	add $t8, $t8, $t0		
	ble $a2, $t5, X_X_draw_loop
	
	lw $v1, v1_2dy_bres2
	lw $a3, a3_2dx_bres1
	lw $t0, t0_d_bres1
	
	blt $t3, $t4, bresXX_1_X_loop #
	b bres_1_2_end
bres_1_X_2_Y:
bresXY_1_X_loop:
	move $v0, $t0	#v0 == t0 == d
	add $t0, $t0, $s4 # d +=2dy
	add $t3, $t3, $s6 # x += xi
	bltz $v0 bresXY_1_X_loop # d < 0 
	add $t3, $t3, $t2 #y +=yi  # dla drugiego trójk¹ta yi = - width
	sub $t0, $t0, $s3 #d -= 2dx
bresXY_2_Y_loop:
	move $v0, $t9 #v0 == t0 == d
	add $t9, $t9, $a3 # d +=2dx
	add $t5, $t5, $t2 #y += yi  # dla drugiego trójk¹ta yi = - width
	bltz $v0 bres_X_Y_draw
	add $t5, $t5, $t7 #x += xi 
	sub $t9, $t9, $v1 #d -= 2dy
bres_X_Y_draw: 
	sw $v1, v1_2dy_bres2 #backing up registers
	sw $a3, a3_2dx_bres1
	sw $t0, t0_d_bres1

	addu $a0, $a0, $k0 # red bres 1 
	addu $a1, $a1, $gp # green bres 1
	addu $t1, $t1, $fp # blue bres 1
	addu $t6, $t6, $k1 # red bres 2
	addu $s2, $s2, $sp # green bres 2
	addu $s5, $s5, $ra # blue bres 2
	
	move $s1, $a0 # red current == red begin 
	move $s7, $a1 # green current == greem begin 
	move $t8, $t1 # blue current == blue begin
X_Y_interpolation:
	sub $v0, $t5, $t3 # $v0 == (x1 - x0)*3 

	sub $s0, $t6, $a0  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $v1		
	add $s0, $v1, $v1	
	add $v1, $v1, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s2, $a1  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $a3
	add $s0, $a3, $a3
	add $a3, $a3, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s5, $t1  # $a1 == (y1 - y0) 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $t0
	add $s0, $t0, $t0
	add $t0, $t0, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
		
	move $a2, $t3 # $a2 = begin()
X_Y_draw_loop:
	srl $v0, $s1, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 2($a2) # red
	srl $v0, $s7, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 1($a2) # green
	srl $v0, $t8, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, ($a2) # blue
	
	addiu $a2, $a2, 3 # ++i
	add $s1, $s1, $v1
	add $s7, $s7, $a3
	add $t8, $t8, $t0		
	ble $a2, $t5, X_Y_draw_loop
	
	lw $v1, v1_2dy_bres2
	lw $a3, a3_2dx_bres1
	lw $t0, t0_d_bres1
	
	blt $t3, $t4, bresXY_1_X_loop #
	b bres_1_2_end
bres_1_Y_2_Y:
bresYY_1_Y_loop:
	move $v0, $t0 #v0 == t0 == d
	add $t0, $t0, $s3 # d +=2dx
	add $t3, $t3, $t2 # y += yi  # dla drugiego trójk¹ta yi = - width
	bltz $v0 bresYY_2_Y_loop
	add $t3, $t3, $s6 # x += xi 
	sub $t0, $t0, $s4 #d -= 2dy
bresYY_2_Y_loop:
	move $v0, $t9 #v0 == t0 == d
	add $t9, $t9, $a3 # d +=2dx
	add $t5, $t5, $t2 #y += yi  # dla drugiego trójk¹ta yi = - width
	bltz $v0 bres_Y_Y_draw
	add $t5, $t5, $t7 #x += xi 
	sub $t9, $t9, $v1 #d -= 2dy
bres_Y_Y_draw: 
	sw $v1, v1_2dy_bres2 #backing up registers
	sw $a3, a3_2dx_bres1
	sw $t0, t0_d_bres1

	addu $a0, $a0, $k0 # red bres 1 
	addu $a1, $a1, $gp # green bres 1
	addu $t1, $t1, $fp # blue bres 1
	addu $t6, $t6, $k1 # red bres 2
	addu $s2, $s2, $sp # green bres 2
	addu $s5, $s5, $ra # blue bres 2
	
	move $s1, $a0 # red current == red begin 
	move $s7, $a1 # green current == greem begin 
	move $t8, $t1 # blue current == blue begin
Y_Y_interpolation:
	sub $v0, $t5, $t3 # $v0 == (x1 - x0)*3 

	sub $s0, $t6, $a0  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $v1		
	add $s0, $v1, $v1	
	add $v1, $v1, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s2, $a1  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $a3
	add $s0, $a3, $a3
	add $a3, $a3, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s5, $t1  # $a1 == (y1 - y0) 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $t0
	add $s0, $t0, $t0
	add $t0, $t0, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
		
	move $a2, $t3 # $a2 = begin()
Y_Y_draw_loop:
	srl $v0, $s1, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 2($a2) # red
	srl $v0, $s7, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 1($a2) # green
	srl $v0, $t8, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, ($a2) # blue
	
	addiu $a2, $a2, 3 # ++i
	add $s1, $s1, $v1
	add $s7, $s7, $a3
	add $t8, $t8, $t0		
	ble $a2, $t5, Y_Y_draw_loop
	
	lw $v1, v1_2dy_bres2
	lw $a3, a3_2dx_bres1
	lw $t0, t0_d_bres1
	
	blt $t3, $t4, bresYY_1_Y_loop
bres_1_2_end:
other_half_of_triangle:
	lw $s0, y3
	lw $s1, y1
	lw $s3, y0
check_if_exist:
	beq $s0, $s1, save_out_file_data #do we need to draw anything at the top
_switch_colors:	
	lw $v0, rotate_if_zero
	bnez $v0, _color_interpolation_prolog	
	lw $v0, color1
	lw $v1, color0		
	sw $v1, color1
	sw $v0, color0
	
	move $v0, $s1
	move $s1, $s3
	move $s3, $v0  
_color_interpolation_prolog:
_red_bres1_interpolation:
	lbu $a0, color3 + 3 # $a0 == y0 == begin().R() 
	lbu $a1, color1 + 3 # $a1 == y1 == end().R()
	sub $a1, $a0, $a1  # $a1 == (y1 - y0)
	sll $a1, $a1, 16 # $a1 == (y1 - y0) # 8.16
	sub $v0, $s1, $s0 # $v0 == (x1 - x0) 
	div $a1, $v0		# red step == (y1 - y0)/(x1 - x0) # 8.16
	mflo $k0		# $k0 == red step bres1 # 8.16
_green_bres1_interpolation:
	lbu $a0, color3 + 2 # $a0 == y0 == begin().G() 
	lbu $a1, color1 + 2 # $a1 == y1 == end().G()
	sub $a1, $a0, $a1 # $a1 == (y1 - y0)
	sll $a1, $a1, 16 # $a1 == (y1 - y0) # 8.16
	div $a1, $v0 # green step == (y1 - y0)/(x1 - x0) # 8.8
	mflo $gp	# $gp == green step bres 1# 8.8
_blue_bres1_interpolation:
	lbu $a0, color3 + 1 # $a0 == y0 == begin().B() 
	lbu $a1, color1 + 1 # $a1 == y1 == end().B()
	sub $a1, $a0, $a1  # $a1 == (y1 - y0)
	sll $a1, $a1, 16 # $a1 == (y1 - y0) # 8.16
	div $a1, $v0	# blue step == (y1 - y0)/(x1 - x0) # 8.8
	mflo $fp	# fp == blue step bres1 # 8.8
_red_bres2_interpolation:
	lbu $a0, color3 + 3 # $a0 == y0 == begin().R() 
	lbu $a1, color0 + 3 # $a1 == y1 == end().R()
	sub $a1, $a0, $a1 # $a1 == (y1 - y0)
	sll $a1, $a1, 16 # $a1 == (y1 - y0) # 8.16
	sub $v0, $s3, $s0 # $v0 == (x1 - x0)
	div $a1, $v0	# red step == (y1 - y0)/(x1 - x0) # 8.8
	mflo $k1	# == red step bres1 # 8.8
_green_bres2_interpolation:
	lbu $a0, color3 + 2 # $a0 == y0 == begin().G() 
	lbu $a1, color0 + 2 # $a1 == y1 == end().G()
	sub $a1, $a0, $a1  # $a1 == (y1 - y0)
	sll $a1, $a1, 16 # $a1 == (y1 - y0) # 8.16
	div $a1, $v0	# (y1 - y0)/(x1 - x0) # 8.8
	mflo $sp	# sp == green step bres2 # 8.8
_blue_bres2_interpolation:
	lbu $a0, color3 + 1 # $a0 == y0 == begin().B() 
	lbu $a1, color0 + 1 # $a1 == y1 == end().B()
	sub $a1, $a0, $a1  # $a1 == (y1 - y0)
	sll $a1, $a1, 16 # $a1 == (y1 - y0) # 8.16
	div $a1, $v0	# (y1 - y0)/(x1 - x0) # 8.8
	mflo $ra	#ra == blue step bres2 # 8.8
_bres_prolog: #s3-5 t4-5 rysujemy zawsze W strone dodatniego y
_reload_points_coords:
	lw $t1, bitmap_begin	
	lw $t2, bitmap_width
	
	lw $a0, x3 #load poins
	lw $s0, y3
	lw $a1, x1
	lw $s1, y1
	lw $a2, x2 # x punktu pomocniczyego
	lw $s2, y2 # y punktu pomocniczyego
_bres_1_begin_adres:
	addu $v0, $a0, $a0
	addu $v0, $v0, $a0
	mul $v1, $s0, $t2
	addu $v0, $v0, $v1
	addu $t3, $v0, $t1 # $t3 == bres 1 begin
_bres_1_end_adres:
	addu $v0, $a1, $a1
	addu $v0, $v0, $a1
	mul $v1, $s1, $t2
	addu $v0, $v0, $v1
	addu $t4, $v0, $t1	
	addu $t4, $t4, $t2
	addu $t4, $t4, -3
_bres_2_begin_adres:
	move $t5, $t3
#bres_2_end_adres: #no need because both lines simultaniosly
	#mul $v0, $a2, 3
	#mul $v1, $s2, $t2
	#addu $v0, $v0, $v1
	#addu $t6, $v0, $t1
_bres_1_dx:
	li  $s6, 3		#s6 == xi == 3 
	sub $s3, $a1, $a0	#s3 == dx
	blt $a0, $a1, _bres_1_dy
	li $s6, -3		#s6 == xi == -3
	sub $s3, $a0, $a1	#s3 == dx
_bres_1_dy:
	sub $s4, $s0, $s1 	#s4 == dy # dla drógiego trójk¹ta to co w komciach
	#sub $s4, $s0, $s1 	#s4 == dy # dla drógiego trójk¹ta to co w komciach
_bres_2_dx:
	li  $t7, 3		#t7 == xi == 3 
	sub $a3, $a2, $a0	#a3 == dx
	blt $a0, $a2, _bres_2_dy
	li $t7, -3		#t7 == xi == -3
	sub $a3, $a0, $a2	#a3 == dx
_bres_2_dy:
	sub $v1, $s0, $s2 	#v1 == dy # dla drógiego trójk¹ta to co w komciach
_bres_2_prolog_choice:	
_bres_2_X_prolog:
	add $v0, $v1, $v1 #v0 == dy *2
	sub $t9, $v0, $a3 #t9 == d == 2dy - dx
_bres_2_Y_prolog:
	bgt $a3, $v1, _bres_2_prolog_addition
	add $v0, $a3, $a3 #v0 == dx *2
	sub $t9, $v0, $v1 #t9 == d == 2dx -dy
_bres_2_prolog_addition:
	add $a3, $a3, $a3 #a3 == dx *2
	add $v1, $v1, $v1 #v4 == dy *2
_bres_1_prolog_choice:
_bres_1_X_prolog:
	add $v0, $s4, $s4 #s4 == dy *2
	sub $t0, $v0, $s3 #t0 == d == 2dy - dx
	bgt $s3, $s4, _bres_1_prolog_addition
_bres_1_Y_prolog:
	add $v0, $s3, $s3 #s3 == dx *2
	sub $t0, $v0, $s4 #t0 == d == 2dx -dy
_bres_1_prolog_addition:
	add $s3, $s3, $s3 #s3 == dx *2
	add $s4, $s4, $s4 #s4 == dy *2
_bres_1_axis_choice:
	lbu $a0, color3 + 3 # red0 
	lbu $a1, color3 + 2 # green0
	lbu $t1, color3 + 1 # blue0
	sb $a0, 2($t3) # red0 
	sb $a1, 1($t3) # green0
	sb $t1, 0($t3) # blue0
	sll $a0, $a0, 16 # red0 8.16
	sll $a1, $a1, 16  # green0 8.16
	sll $t1, $t1, 16 # blue0 8.16
	move $t6, $a0  # red0 
	move $s2, $a1 # green0 
	move $s5, $t1 # blue0
	
	ble $s3, $s4, _bres_1_Y
_bres_1_X:
	ble $a3, $v1, _bres_1_X_2_Y # bres_2_axis_choice:
	b  _bres_1_X_2_X
_bres_1_Y:
	ble $a3, $v1, _bres_1_Y_2_Y # bres_2_axis_choice:
_bres_1_Y_2_X:
_bresYX_2_X_loop:
	move $v0, $t9	#v0 == t0 == d
	add $t9, $t9, $v1 # d +=2dy
	add $t5, $t5, $t7 # x += xi # not safe for line triangle
	bltz $v0 _bresYX_2_X_loop # d < 0 
	sub $t5, $t5, $t2 #y +=yi  # dla drugiego trójk¹ta yi = - width
	sub $t9, $t9, $a3 #d -= 2dx
_bresYX_1_Y_loop:
	move $v0, $t0 #v0 == t0 == d
	add $t0, $t0, $s3 # d +=2dx
	sub $t3, $t3, $t2 #y += yi  # dla drugiego trójk¹ta yi = - width
	bltz $v0 _bres_Y_X_draw
	add $t3, $t3, $s6 #x+=xi 
	sub $t0, $t0, $s4 #d -= 2dy
_bres_Y_X_draw: 
	sw $v1, v1_2dy_bres2 #backing up registers
	sw $a3, a3_2dx_bres1
	sw $t0, t0_d_bres1

	addu $a0, $a0, $k0 # red bres 1 
	addu $a1, $a1, $gp # green bres 1
	addu $t1, $t1, $fp # blue bres 1
	addu $t6, $t6, $k1 # red bres 2
	addu $s2, $s2, $sp # green bres 2
	addu $s5, $s5, $ra # blue bres 2
	
	move $s1, $a0 # red current == red begin 
	move $s7, $a1 # green current == greem begin 
	move $t8, $t1 # blue current == blue begin
_Y_X_interpolation:
	sub $v0, $t5, $t3 # $v0 == (x1 - x0)*3 

	sub $s0, $t6, $a0  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $v1		
	add $s0, $v1, $v1	
	add $v1, $v1, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s2, $a1  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $a3
	add $s0, $a3, $a3
	add $a3, $a3, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s5, $t1  # $a1 == (y1 - y0) 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $t0
	add $s0, $t0, $t0
	add $t0, $t0, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
		
	move $a2, $t3 # $a2 = begin()
_Y_X_draw_loop:
	srl $v0, $s1, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 2($a2) # red
	srl $v0, $s7, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 1($a2) # green
	srl $v0, $t8, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, ($a2) # blue
	
	addiu $a2, $a2, 3 # ++i
	add $s1, $s1, $v1
	add $s7, $s7, $a3
	add $t8, $t8, $t0		
	ble $a2, $t5, _Y_X_draw_loop
	
	lw $v1, v1_2dy_bres2
	lw $a3, a3_2dx_bres1
	lw $t0, t0_d_bres1 
			
	bgt $t3, $t4, _bresYX_2_X_loop #
	b _bres_1_2_end
_bres_1_X_2_X:
_bresXX_1_X_loop:
	move $v0, $t0	#v0 == t0 == d
	add $t0, $t0, $s4 # d +=2dy
	add $t3, $t3, $s6 # x += xi
	bltz $v0 _bresXX_1_X_loop # d < 0 # not safe for line triangle
	sub $t3, $t3, $t2 #y +=yi  # dla drugiego trójk¹ta yi = - width
	sub $t0, $t0, $s3 #d -= 2dx
_bresXX_2_X_loop:
	move $v0, $t9	#v0 == t0 == d
	add $t9, $t9, $v1 # d +=2dy
	add $t5, $t5, $t7 # x += xi
	bltz $v0 _bresXX_2_X_loop # d < 0 # not safe for line triangle
	sub $t5, $t5, $t2 #y +=yi  # dla drugiego trójk¹ta yi = - width
	sub $t9, $t9, $a3 #d -= 2dx
_bres_X_X_draw: 
	sw $v1, v1_2dy_bres2 #backing up registers
	sw $a3, a3_2dx_bres1
	sw $t0, t0_d_bres1

	addu $a0, $a0, $k0 # red bres 1 
	addu $a1, $a1, $gp # green bres 1
	addu $t1, $t1, $fp # blue bres 1
	addu $t6, $t6, $k1 # red bres 2
	addu $s2, $s2, $sp # green bres 2
	addu $s5, $s5, $ra # blue bres 2
	
	move $s1, $a0 # red current == red begin 
	move $s7, $a1 # green current == greem begin 
	move $t8, $t1 # blue current == blue begin
_X_X_interpolation:
	sub $v0, $t5, $t3 # $v0 == (x1 - x0)*3 

	sub $s0, $t6, $a0  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $v1		
	add $s0, $v1, $v1	
	add $v1, $v1, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s2, $a1  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $a3
	add $s0, $a3, $a3
	add $a3, $a3, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s5, $t1  # $a1 == (y1 - y0) 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $t0
	add $s0, $t0, $t0
	add $t0, $t0, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
		
	move $a2, $t3 # $a2 = begin()
_X_X_draw_loop:
	srl $v0, $s1, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 2($a2) # red
	srl $v0, $s7, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 1($a2) # green
	srl $v0, $t8, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, ($a2) # blue
	
	addiu $a2, $a2, 3 # ++i
	add $s1, $s1, $v1
	add $s7, $s7, $a3
	add $t8, $t8, $t0		
	ble $a2, $t5, _X_X_draw_loop
	
	lw $v1, v1_2dy_bres2
	lw $a3, a3_2dx_bres1
	lw $t0, t0_d_bres1
	
	bgt $t3, $t4, _bresXX_1_X_loop #
	b _bres_1_2_end
_bres_1_X_2_Y:
_bresXY_1_X_loop:
	move $v0, $t0	#v0 == t0 == d
	add $t0, $t0, $s4 # d +=2dy
	add $t3, $t3, $s6 # x += xi
	bltz $v0 _bresXY_1_X_loop # d < 0 
	sub $t3, $t3, $t2 #y +=yi  # dla drugiego trójk¹ta yi = - width
	sub $t0, $t0, $s3 #d -= 2dx
_bresXY_2_Y_loop:
	move $v0, $t9 #v0 == t0 == d
	add $t9, $t9, $a3 # d +=2dx
	sub $t5, $t5, $t2 #y += yi  # dla drugiego trójk¹ta yi = - width
	bltz $v0 _bres_X_Y_draw
	add $t5, $t5, $t7 #x += xi 
	sub $t9, $t9, $v1 #d -= 2dy
_bres_X_Y_draw: 
	sw $v1, v1_2dy_bres2 #backing up registers
	sw $a3, a3_2dx_bres1
	sw $t0, t0_d_bres1

	addu $a0, $a0, $k0 # red bres 1 
	addu $a1, $a1, $gp # green bres 1
	addu $t1, $t1, $fp # blue bres 1
	addu $t6, $t6, $k1 # red bres 2
	addu $s2, $s2, $sp # green bres 2
	addu $s5, $s5, $ra # blue bres 2
	
	move $s1, $a0 # red current == red begin 
	move $s7, $a1 # green current == greem begin 
	move $t8, $t1 # blue current == blue begin
_X_Y_interpolation:
	sub $v0, $t5, $t3 # $v0 == (x1 - x0)*3 

	sub $s0, $t6, $a0  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $v1		
	add $s0, $v1, $v1	
	add $v1, $v1, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s2, $a1  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $a3
	add $s0, $a3, $a3
	add $a3, $a3, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s5, $t1  # $a1 == (y1 - y0) 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $t0
	add $s0, $t0, $t0
	add $t0, $t0, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
		
	move $a2, $t3 # $a2 = begin()
_X_Y_draw_loop:
	srl $v0, $s1, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 2($a2) # red
	srl $v0, $s7, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 1($a2) # green
	srl $v0, $t8, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, ($a2) # blue
	
	addiu $a2, $a2, 3 # ++i
	add $s1, $s1, $v1
	add $s7, $s7, $a3
	add $t8, $t8, $t0		
	ble $a2, $t5, _X_Y_draw_loop
	
	lw $v1, v1_2dy_bres2
	lw $a3, a3_2dx_bres1
	lw $t0, t0_d_bres1
	
	bgt $t3, $t4, _bresXY_1_X_loop #
	b _bres_1_2_end
_bres_1_Y_2_Y:
_bresYY_1_Y_loop:
	move $v0, $t0 #v0 == t0 == d
	add $t0, $t0, $s3 # d +=2dx
	sub $t3, $t3, $t2 # y += yi  # dla drugiego trójk¹ta yi = - width
	bltz $v0 _bresYY_2_Y_loop
	add $t3, $t3, $s6 # x += xi 
	sub $t0, $t0, $s4 #d -= 2dy
_bresYY_2_Y_loop:
	move $v0, $t9 #v0 == t0 == d
	add $t9, $t9, $a3 # d +=2dx
	sub $t5, $t5, $t2 #y += yi  # dla drugiego trójk¹ta yi = - width
	bltz $v0 _bres_Y_Y_draw
	add $t5, $t5, $t7 #x += xi 
	sub $t9, $t9, $v1 #d -= 2dy
_bres_Y_Y_draw: 
	sw $v1, v1_2dy_bres2 #backing up registers
	sw $a3, a3_2dx_bres1
	sw $t0, t0_d_bres1

	addu $a0, $a0, $k0 # red bres 1 
	addu $a1, $a1, $gp # green bres 1
	addu $t1, $t1, $fp # blue bres 1
	addu $t6, $t6, $k1 # red bres 2
	addu $s2, $s2, $sp # green bres 2
	addu $s5, $s5, $ra # blue bres 2
	
	move $s1, $a0 # red current == red begin 
	move $s7, $a1 # green current == greem begin 
	move $t8, $t1 # blue current == blue begin
_Y_Y_interpolation:
	sub $v0, $t5, $t3 # $v0 == (x1 - x0)*3 

	sub $s0, $t6, $a0  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $v1		
	add $s0, $v1, $v1	
	add $v1, $v1, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s2, $a1  # $a1 == (y1 - y0) # 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $a3
	add $s0, $a3, $a3
	add $a3, $a3, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
	
	sub $s0, $s5, $t1  # $a1 == (y1 - y0) 8.16
	div $s0, $v0 # (y1 - y0)/((x1 - x0)*3) # 8.16
	mflo $t0
	add $s0, $t0, $t0
	add $t0, $t0, $s0 # 3 * (y1 - y0)/((x1 - x0)*3) # 8.16
		
	move $a2, $t3 # $a2 = begin()
_Y_Y_draw_loop:
	srl $v0, $s1, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 2($a2) # red
	srl $v0, $s7, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, 1($a2) # green
	srl $v0, $t8, 16 # $v0 == y0 + (x - x0)*(y1 - y0)/(x1 - x0) #8.0
	sb $v0, ($a2) # blue
	
	addiu $a2, $a2, 3 # ++i
	add $s1, $s1, $v1
	add $s7, $s7, $a3
	add $t8, $t8, $t0		
	ble $a2, $t5, _Y_Y_draw_loop
	
	lw $v1, v1_2dy_bres2
	lw $a3, a3_2dx_bres1
	lw $t0, t0_d_bres1
	
	bgt $t3, $t4, _bresYY_1_Y_loop
_bres_1_2_end:
save_out_file_data:
open_out_file2:
	la $a0, output_file	# wczytanie nazwy pliku do otwarcia
	li $a1, 1	# flagi otwarcia
	li $a2, 0	# tryb otwarcia
	li $v0, 13	# ustawienie syscall na otwieranie pliku
	syscall		# otwarcie pliku, zostawienie w $v0 jego deskryptora
	
	move $t0, $v0	# przekopiowanie deskryptora do rejestru t0
	bltz $t0, save_file_err	# przeskocz do blad_plik_out jesli wczytywanie sie nie powiodlo
write_to_out_file_from_memory:
	lw $t7, size
	lw $t1, memory 			
	move $a0, $t0	# przekopiowanie deskryptora do a0
	la $a1, ($t1)	# wskazanie wczesniej zaalokowanej pamieci jako danych do zapisania
	la $a2, ($t7)	# ustawienie zapisu tylu bajtow ile ma plik
	li $v0, 15	# ustawienie syscall na zapis do pliku
	syscall		# wczytanie wysokosci bitmapy
close_out_file2:
	move $a0, $t0	# przekopiowanie deskryptora pliku do a0
	li $v0, 16	# ustawienie syscall na zakmniecie pliku
	syscall		# zamkniecie pliku o deskryptorze w a0
exit:
	li $v0, 10
	syscall 
input_file_err:
	li $v0, 4
	la $a0, m_in_file_err
	syscall
output_file_err:
	li $v0, 4
	la $a0, m_out_file_err
	syscall
save_file_err:
	li $v0, 4
	la $a0, m_out_save_err
	syscall
case_not_implemented:
	li $v0, 4
	la $a0, m_case_not_implemented
	syscall	
exit2:
	li $v0, 10
	syscall 
	

	
	
	
