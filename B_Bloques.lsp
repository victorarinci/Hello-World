;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;				O	P	E	R	A	C	I	O	N	E	S		C	O	N		B	L	O	Q	U	E	S
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(defun |B|EXTRAE ()
	(setq b_defblk (tblnext "BLOCK" T) b_lblocks '())
	(setq b_nocodes (list -1 0 100 5 330 340 67) b_partcodes (list 10 11 210))
	(while b_defblk
		(setq b_nom (|O|ITEM 2 b_defblk) b_nsent (|O|ITEM -2 b_defblk) b_lisent '() b_sent (entget b_nsent) b_lisatt '()
		      b_lblocks (cons (list (strcat "; elementos para el bloque " b_nom)) b_lblocks) b_cent 1 b_catt 1
		)
		(while b_nsent
			(setq b_sent (entget b_nsent) b_tip (|O|ITEM 0 b_sent))
			(if (eq b_tip "ATTDEF")
				(setq b_lisatt (cons b_sent b_lisatt))
				(setq b_lisent (cons b_sent b_lisent))
			)
			(setq b_nsent (entnext b_nsent))
		)
		(if b_lisent
			(foreach b_sent (reverse b_lisent)
				(setq b_strlin (strcat "(setq b_" (itoa b_cent) " (list (cons 0 \"" (|O|ITEM 0 b_sent) "\") ") b_strl2 nil)
				(foreach b_item b_sent
					(if (> (strlen b_strlin) 200) (setq b_strl2 b_strlin b_strlin ""))
					(setq b_code (car b_item) b_rest (cdr b_item))
					(if (not (member b_code b_nocodes))
					(progn
						(if (not (member b_code b_partcodes))
							(setq b_strlin (strcat b_strlin "(cons " (itoa b_code)))
							(setq b_strlin (strcat b_strlin "(list " (itoa b_code)))
						)
						(setq b_tipo (type b_rest))
						(cond ((eq b_tipo 'INT)
								(setq b_strlin (strcat b_strlin " " (itoa b_rest)))
							)
							((eq b_tipo 'REAL)
								(setq b_strlin (strcat b_strlin " " (rtos b_rest 2 5)))
							)
							((eq b_tipo 'LIST)
								(foreach b_sitem b_rest
									(setq b_strlin (strcat b_strlin " " (rtos b_sitem 2 5)))
								)
							)
							(T
								(setq b_strlin (strcat b_strlin " \"" b_rest "\""))
							)
						)
						(setq b_strlin (strcat b_strlin ") "))
					))		
					(if b_strl2 (setq b_lblocks (cons (list b_strl2) b_lblocks) b_strl2 nil))
				)
				(setq b_strlin (strcat b_strlin "))")
				      b_lblocks (cons (list b_strlin) b_lblocks)
				      b_cent (1+ b_cent)
				)
			)
		)
		(if b_lisatt
			(foreach b_sent (reverse b_lisatt)
				(setq b_strlin (strcat "(setq b_" (itoa b_catt) " (list (cons 0 \"" (|O|ITEM 0 b_sent) "\") ") b_strl2 nil)
				(foreach b_item b_sent
					(if (> (strlen b_strlin) 200) (setq b_strl2 b_strlin b_strlin ""))
					(setq b_code (car b_item) b_rest (cdr b_item))
					(if (not (member b_code b_nocodes))
					(progn
						(if (not (member b_code b_partcodes))
							(setq b_strlin (strcat b_strlin "(cons " (itoa b_code)))
							(setq b_strlin (strcat b_strlin "(list " (itoa b_code)))
						)
						(setq b_tipo (type b_rest))
						(cond ((eq b_tipo 'INT)
								(setq b_strlin (strcat b_strlin " " (itoa b_rest)))
							)
							((eq b_tipo 'REAL)
								(setq b_strlin (strcat b_strlin " " (rtos b_rest 2 5)))
							)
							((eq b_tipo 'LIST)
								(foreach b_sitem b_rest
									(setq b_strlin (strcat b_strlin " " (rtos b_sitem 2 5)))
								)
							)
							(T
								(setq b_strlin (strcat b_strlin " \"" b_rest "\""))
							)
						)
						(setq b_strlin (strcat b_strlin ") "))
					))		
					(if b_strl2 (setq b_lblocks (cons (list b_strl2) b_lblocks) b_strl2 nil))
				)
				(setq b_strlin (strcat b_strlin "))")
				      b_lblocks (cons (list b_strlin) b_lblocks)
				      b_catt (1+ b_catt)
				)
			)
		)
		(setq b_defblk (tblnext "BLOCK"))
	)
	(|F|GUARDAR g_path "Bloques" "TXT" nil (reverse b_lblocks) " " T)
)

;Verificar la existencia de un bloque
;"|B|BUSCAR"
(defun |B|BUSCAR (b_bname)
	(tblsearch "Block" b_bname)
)

;Definir un BLOQUE
;"|B|BLOCK"
(defun |B|BLOCK (b_bname b_pto b_lay b_bent b_batt)
;	(|O|CHECKTSTYLE o_liscomp)
;	(|O|CHECKTSTYLE o_lisatt)
;	(setq b_liscomp (|O|CHECKLSTYLE b_liscomp))
	(if (not b_bent) (setq b_bent (|O|EVAL (strcat "b_" b_bname "ent"))))
	(if (not b_batt) (setq b_batt (|O|EVAL (strcat "b_" b_bname "att"))))
	(if (not b_pto) (setq b_pto '(0 0 0)))
	(if (not b_lay) (setq b_lay "0"))
	(if (not (|B|BUSCAR b_bname))
		(progn
			(if b_batt (setq b_70 2) (setq b_70 0))
			(entmake	(list	(cons 0 "BLOCK")
						(cons 100 "AcDbEntity")
						(cons 8 b_lay)
						(cons 100 "AcDbBlockBegin")
						(cons 2 b_bname)
						(cons 10 b_pto)
						(cons 70 b_70)
					)
			)
			(|O|POINT b_pto 0 "0")
			(if b_bent 
				(foreach b_ent b_bent
					(entmake b_ent)
				)
			)
			(if b_batt
				(foreach b_att b_batt
					(entmake b_att)
				)
			)
			(entmake	(list	(cons 0 "ENDBLK")
						(cons 100 "AcDbEntity")
						(cons 100 "AcDbBlockEnd")
					)
			)
		)
	)
	(|B|BUSCAR b_bname)
)

;"|B|ESATT"
(defun |B|ESATT (b_ent)
	(eq (|O|ITEM 0 b_ent) "ATTDEF")
)

;"|B|LOOP"
(defun |B|LOOP (b_enom b_latt b_lent)
	(cond ((null b_enom) nil)
		((|B|ESATT (entget b_enom)) b_enom)
		(T (|B|LOOP (entnext b_enom)))
	)
)

;crear una lista con las entidades de un bloque
;"|B|LISTENT"
(defun |B|LISTENT (b_bname / b_lent b_latt)
	(setq b_entp (|B|BUSCAR b_bname) b_nsent (|O|ITEM -2 b_entp) b_lent '() b_latt '())
	(while b_nsent
		(setq b_sent (entget b_nsent))
		(if (|B|ESATT b_sent)
			(setq b_latt (cons b_sent b_latt))
			(setq b_lent (cons b_sent b_lent))
		)
		(setq b_nsent (entnext b_nsent))
	)
	(list b_bname (reverse b_lent) (reverse b_latt))
)

;Verificar si un bloque tiene atributos
;"|B|TIENEATT"
(defun |B|TIENEATT (b_bname)
	(cond ((setq b_entp (|B|BUSCAR b_bname))
			(setq b_nsent (|O|ITEM -2 b_entp))
			(|B|LOOP b_nsent)
		)
		(T nil)
	)
)

;crear una lista con los tags de los atributos de un bloque
;"|B|LTATT"
(defun |B|LTATT (b_bname / b_latt)
	(cond ((setq b_entp (|B|BUSCAR b_bname))
			(setq b_nsent (|O|ITEM -2 b_entp) b_latt '() b_catt 1)
			(while (setq b_natt (|B|LOOP b_nsent))
				(setq b_attl (entget b_natt) b_latt (cons (list b_catt (|O|ITEM 2 (entget b_natt))) b_latt) b_catt (1+ b_catt) b_nsent (entnext b_natt))
			)
			b_latt
		)
		(T nil)
	)
)

;Devolver el valor de un atributo determinado del bloque
;"|B|ATTVAL"
(defun |B|ATTVAL (b_entp b_index)
	(setq b_entp (entnext b_entp))
	(cond ((= b_index 1)
			(setq b_att (|O|ITEM 1 (entget b_entp)))
		)
		(T (|B|ATTVAL b_entp (1- b_index)))
	)
)

;"|B|ATTDEF"
(defun |B|ATTDEF (b_def b_pt b_pt2 b_ang b_hgt b_wdt b_toa b_sty b_tag b_prmpt b_jh b_jv b_gt b_flag b_lay)
	(entmake	(list (cons 0 "ATTDEF")
				(cons 100 "AcDbEntity")
				(cons 8 b_lay)
				(cons 100 "AcDbText") 
				(cons 10 b_pt)
				(cons 40 b_hgt)
				(cons 1 b_def)
				(cons 50 b_ang)
				(cons 41 b_wdt)
				(cons 51 b_toa)
				(cons 7 b_sty)
				(cons 71 b_gt)
				(cons 72 b_jh)
				(cons 11 b_pt2)
				(cons 100 "AcDbAttributeDefinition")
				(cons 74 b_jv)
				(cons 3 b_prmpt)
				(cons 2 b_tag)
				(cons 70 0)
			)
	)
)

;"|B|ATTRIB"
(defun |B|ATTRIB (b_val b_pt b_pt2 b_ang b_hgt b_wdt b_toa b_sty b_tag b_jh b_jv b_gt b_lay)
;	(setq b_ctab (getvar "CTAB"))
; 	(if (eq b_ctab "Model") (setq b_tile 0) (setq b_tile 1))
	(cond
		((= (|N|CUADRANTE b_ang) 2)
			(setq b_ang (+ b_ang PI))
			(if (= b_jh 0) (setq b_jh 2) (if (= b_jh 2) (setq b_jh 0)))
			(if (or (= b_jv 0) (= b_jv 1)) (setq b_jv 3) (if (= b_jv 3) (setq b_jv 1)))
		)
		((= (|N|CUADRANTE b_ang) 3)
			(setq b_ang (- b_ang PI))
			(if (= b_jh 0) (setq b_jh 2) (if (= b_jh 2) (setq b_jh 0)))
			(if (or (= b_jv 0) (= b_jv 1)) (setq b_jv 3) (if (= b_jv 3) (setq b_jv 1)))
		)
	)
	(entmake	(list (cons 0 "ATTRIB")
				(cons 100 "AcDbEntity")
;				(cons 67 b_tile)
;				(cons 410 b_ctab)
				(cons 8 b_lay)
				(cons 100 "AcDbText") 
				(cons 10 b_pt)
				(cons 40 b_hgt)
				(cons 1 b_val)
				(cons 50 b_ang)
				(cons 41 b_wdt)
				(cons 51 b_toa)
				(cons 7 b_sty)
				(cons 71 b_gt)
				(cons 72 b_jh)
				(cons 11 b_pt2)
				(cons 100 "AcDbAttribute")
				(cons 74 b_jv)
				(cons 2 b_tag)
				(cons 70 0)
			)
	)
)

;insertar un BLOQUE
;"|B|INSERT"
(defun |B|INSERT (b_bname b_pto b_lay b_ang b_esc b_lvatt)
	(setq b_entp (|B|BLOCK b_bname (list 0 0 0) "0" nil nil))
	(setq b_nsent (|O|ITEM -2 b_entp) b_pins (|O|ITEM 10 b_entp) b_lisent '() b_sent (entget b_nsent) b_lisatt '())
	(while (setq b_nsent (entnext b_nsent))
		(setq b_sent (entget b_nsent) b_tip (|O|ITEM 0 b_sent))
		(if (eq b_tip "ATTDEF")
			(setq b_lisatt (cons b_sent b_lisatt))
		)
	)
	(if (listp b_esc) (setq b_ex (car b_esc) b_ey (cadr b_esc) b_ez (last b_esc)) (setq b_ex b_esc b_ey b_esc b_ez b_esc))
	(if b_lisatt (setq b_66 1) (setq b_66 0))
	(if b_lvatt (setq b_66 1) (setq b_66 0))
	(entmake (list	(cons 0 "INSERT")
				(cons 100 "AcDbEntity")
				(cons 8 b_lay)
				(cons 100 "AcDbBlockReference")
				(cons 66 b_66)
				(cons 2 b_bname)
				(cons 10 b_pto)
				(cons 41 b_ex)
				(cons 42 b_ey)
				(cons 43 b_ez)
				(cons 50 b_ang)
		     )
	)
	(if b_lisatt
		(progn
			(setq b_attc 0 b_lisatt (reverse b_lisatt))
			(while (setq b_att (nth b_attc b_lisatt))
				(setq b_atval (nth b_attc b_lvatt)
					b_atpto1 (|O|ITEM 10 b_att) b_atpto2 (|O|ITEM 11 b_att)
					b_atang (+ (|O|ITEM 50 b_att) b_ang)
					b_atpt1 (|K|POLAR b_pto (+ (|K|ANG b_pins b_atpto1) b_ang) (* (|K|DISTH b_pins b_atpto1) b_ex))
					b_atpt2 (|K|POLAR b_atpt1 (+ (|K|ANG b_atpto1 b_atpto2) b_ang) (* (|K|DISTH b_atpto1 b_atpto2) b_ex))
					b_atth (* (|O|ITEM 40 b_att) b_ex)
					b_atlay (|O|ITEM 8 b_att)
					b_attw (|O|ITEM 41 b_att)
					b_attst (|O|ITEM 7 b_att)
					b_attag (|O|ITEM 2 b_att)
					b_attjh (|O|ITEM 72 b_att)
					b_attjv (|O|ITEM 74 b_att)
					b_attg (|O|ITEM 71 b_att)
					b_attoa (|O|ITEM 51 b_att)
				)
				(|B|ATTRIB b_atval b_atpt1 b_atpt2 b_atang b_atth b_attw b_attoa b_attst b_attag b_attjh b_attjv b_attg b_atlay)
				(setq b_attc (1+ b_attc))
			)
			(entmake (list (cons 0 "SEQEND") (cons 8 b_lay)))
		)
	)
)

;explotar un BLOQUE
;"|B|EXPLOT"
(defun |B|EXPLOT (b_ename)
	(defun |B|TRANSPT (b_pt)
		(setq b_pa (list (+ (car b_pins) (* (car b_pt) b_ex)) (+ (cadr b_pins) (* (cadr b_pt) b_ey)) (if (caddr b_pt) (+ (caddr b_pins) (* (caddr b_pt) b_ez)) 0.0)))
		(|K|POLAR b_pins (+ (|K|ANG b_pins b_pa) b_ang) (|K|DISTH b_pins b_pa))
	)
	(defun |B|A2T (b_at / b_t b_lisa b_num)
		(setq b_t '((0 . "TEXT")) b_layo (|O|ITEM 8 b_at))
		(if (= b_layo "0") (setq b_at (|O|REEMP 8 b_lay b_at)))
	 	(ForEach b_num '(8 6 38 39 62 67 210 10 40 1 50 41 51 7 71 72 73 11 74)
			(if (setq b_lisa (assoc b_num b_at))
				(setq b_t (cons b_lisa b_t))
			)
		)
		(setq b_t (subst (cons 73 (|O|ITEM 74 b_at)) (assoc 74 b_t) b_t))
		(entmake (reverse b_t))
	)
	(defun |B|CONSENT (b_lent)
		(setq b_layo (|O|ITEM 8 b_ent) b_nent '())
		(if (= b_layo "0") (setq b_layo b_lay))
		(setq b_nent '())
		(foreach b_item b_lent
			(setq b_nit (car b_item))
			(cond
				((= b_nit 8) (setq b_nent (cons (cons 8 b_layo) b_nent)))
				((|N|ENTRE b_nit '(10 15))
					(setq b_nent (cons (cons b_nit (|B|TRANSPT (cdr b_item))) b_nent))
				)
				((= b_nit 40)
					(setq b_nent (cons (cons b_nit (* (cdr b_item) (abs b_ex))) b_nent))
				)
				((= b_nit 50)
					(setq b_nent (cons (cons b_nit (+ (cdr b_item) b_ang)) b_nent))
				)
				(T (setq b_nent (cons b_item b_nent)))
			)
		)
		(if (/= b_layout "Model") (setq b_nent (cons (cons 410 b_layout) (cons (cons 67 1) b_nent))))
		(entmake (reverse b_nent))
	)

	(setq b_entb (entget b_ename) b_bname (|O|ITEM 2 b_entb) b_pins (|O|ITEM 10 b_entb)
	      b_ang (|O|ITEM 50 b_entb) b_ex (|O|ITEM 41 b_entb) b_ey (|O|ITEM 42 b_entb) b_ez (|O|ITEM 43 b_entb)
	      b_lay (|O|ITEM 8 b_entb) b_66 (|O|ITEM 66 b_entb) b_layout (|O|ITEM 410 b_entb)
	      b_entp (|B|BUSCAR b_bname)
	      b_nsent (|O|ITEM -2 b_entp) b_lisent '() b_sent (entget b_nsent) b_lisatt '()
	)
	(if (= (|O|ITEM 66 b_entb) 1)
          (progn
		(setq b_nat b_ename)
       		(while (setq b_nat (entnext b_nat) b_att (entget b_nat) b_tip (|O|ITEM 0 b_att) b_esat (= "ATTRIB" b_tip))
            			(|B|A2T b_att)
       		)
          )
	)
	(setq b_lisent (cadr (|B|LISTENT b_bname)))
	(foreach b_ent b_lisent
		(if (and (= (|O|ITEM 0 b_ent) "ARC") (minusp b_ex))
			(if (minusp b_ey)
				(setq b_c50 (|O|ITEM 50 b_ent) b_c51 (|O|ITEM 51 b_ent) b_ent (|O|REEMP 50 (+ b_c50 PI) (|O|REEMP 51 (+ b_c51 PI) b_ent)))
				(setq b_c50 (|O|ITEM 50 b_ent) b_c51 (|O|ITEM 51 b_ent) b_ent (|O|REEMP 51 (- PI b_c50) (|O|REEMP 50 (- PI b_c51) b_ent)))
			)
		)
		(|B|CONSENT b_ent)
	)
	(entdel b_ename)
)

;"|B|ESCG"
(defun |B|ESCG (b_pi b_eh b_ev b_un / b_lisatt)
	(defun |B|CLATT (b_lbase b_esc / b_num)
		(if (< b_esc 10) (setq b_dd 2) (setq b_dd 1))
		(cond
			((null b_lbase) nil)
			((null (car b_lbase)) (cons "" (|B|CLATT (cdr b_lbase) b_esc)))
			((= (length b_lbase) 1)
				(setq b_num (* (car b_lbase) b_esc))
				(if (equal b_num (fix b_num) 0.01)
					(list (strcat (rtos b_num 2 0) b_un))
					(list (strcat (rtos b_num 2 b_dd) b_un))
				)
			)
			(T
				(setq b_num (* (car b_lbase) b_esc))
				(if (equal b_num (fix b_num) 0.01)
					(cons (rtos b_num 2 0) (|B|CLATT (cdr b_lbase) b_esc))
					(cons (rtos b_num 2 b_dd) (|B|CLATT (cdr b_lbase) b_esc))
				)
			)
		)
	)
  
	(if b_ev (setq b_th "H:0" b_tv "V:0") (setq b_th "0"))
	(cond
		((or (= b_eh 1) (= b_eh 10) (= b_eh 100) (= b_eh 1000) (= b_eh 10000) (= b_eh 100000))
			(|B|INSERT "EG" b_pi "L_SIMBOLOS" 0 1 (cons b_th (|B|CLATT (list 0.01 nil nil 0.05 0.1) b_eh)))
		)
		((or (= b_eh 2) (= b_eh 20) (= b_eh 200) (= b_eh 2000) (= b_eh 20000))
			(|B|INSERT "EG" b_pi "L_SIMBOLOS" 0 1 (cons b_th (|B|CLATT (list nil nil 0.025 0.05 0.1) b_eh)))
		)
		((or (= b_eh 2.5) (= b_eh 25) (= b_eh 250) (= b_eh 2500) (= b_eh 25000))
			(|B|INSERT "EG" b_pi "L_SIMBOLOS" 0 1 (cons b_th (|B|CLATT (list nil 0.02 nil 0.05 0.1) b_eh)))
		)
		((or (= b_eh 5) (= b_eh 50) (= b_eh 500) (= b_eh 5000) (= b_eh 50000))
			(|B|INSERT "EG" b_pi "L_SIMBOLOS" 0 1 (cons b_th (|B|CLATT (list 0.01 0.02 nil 0.05 0.1) b_eh)))
		)
		((or (= b_eh 7.5) (= b_eh 75) (= b_eh 750) (= b_eh 7500) (= b_eh 75000))
			(|B|INSERT "EG" b_pi "L_SIMBOLOS" 0 1 (cons b_th (|B|CLATT (list 0.01 nil nil 0.05 0.1) b_eh)))
		)
	)
	(if b_ev
		(cond
			((or (= b_ev 1) (= b_ev 10) (= b_ev 100) (= b_ev 1000) (= b_ev 10000) (= b_ev 100000))
				(|B|INSERT "EGV" b_pi "L_SIMBOLOS" 0 1 (cons b_tv (|B|CLATT (list 0.01 nil nil 0.05 0.1) b_ev)))
			)
			((or (= b_ev 2) (= b_ev 20) (= b_ev 200) (= b_ev 2000) (= b_ev 20000))
				(|B|INSERT "EGV" b_pi "L_SIMBOLOS" 0 1 (cons b_tv (|B|CLATT (list nil nil 0.025 0.05 0.1) b_ev)))
			)
			((or (= b_ev 2.5) (= b_ev 25) (= b_ev 250) (= b_ev 2500) (= b_ev 25000))
				(|B|INSERT "EGV" b_pi "L_SIMBOLOS" 0 1 (cons b_tv (|B|CLATT (list nil 0.02 nil 0.05 0.1) b_ev)))
			)
			((or (= b_ev 5) (= b_ev 50) (= b_ev 500) (= b_ev 5000) (= b_ev 50000))
				(|B|INSERT "EGV" b_pi "L_SIMBOLOS" 0 1 (cons b_tv (|B|CLATT (list 0.01 0.02 nil 0.05 0.1) b_ev)))
			)
			((or (= b_ev 7.5) (= b_ev 75) (= b_ev 750) (= b_ev 7500) (= b_ev 75000))
				(|B|INSERT "EGV" b_pi "L_SIMBOLOS" 0 1 (cons b_tv (|B|CLATT (list 0.01 nil nil 0.05 0.1) b_ev)))
			)
		)
	)
)

;reemplazar un bloque por otro
;"|B|REEMP"
(defun |B|REEMP (b_oname b_nname)
	(|G|SET0VAR)  
	(setq b_lbv (|B|LISTENT b_oname) b_lbn (|B|LISTENT b_nname) b_i 0 b_catv (length (last b_lbv)) b_catn (length (last b_lbn)))
	(|B|BLOCK b_nname (list 0 0 0) "0" nil nil)
	(if (eq (strcase (getstring "reemplazar Todas las instancias del bloque o Seleccionar: ")) "T")
		(setq b_ssloop (|L|SSL (ssget "X" '((-4 . "<AND") (0 . "INSERT") (cons 2  b_oname) (-4 . "AND>")))))
		(setq b_ssloop (|L|SSL (ssget  '((-4 . "<AND") (0 . "INSERT") (cons 2  b_oname) (-4 . "AND>")))))
	)
	(while (setq b_obj (car b_ssloop))
		(setq b_objl (entget b_obj)
		      b_pin (|O|ITEM 10 b_objl)
		      b_angi (+ (|O|ITEM 50 b_objl) PI)
		      b_efx (|O|ITEM 41 b_objl)
		      b_efy (|O|ITEM 42 b_objl)
		      b_efz (|O|ITEM 43 b_objl)
		      b_lay (|O|ITEM 8 b_objl)
		      b_latt '() b_ssloop (cdr b_ssloop)
		)
		(cond ((< b_catv b_catn)
				(setq b_dif (- b_catn b_catv) b_pobj b_obj)
				(repeat b_catv
					(setq b_pobj (entnext b_pobj) b_attl (entget b_pobj) 
						b_latt (cons (|O|ITEM 1 b_attl) b_latt)
					)
				)
				(setq b_latl (|L|ULTL b_lbn b_dif))
				(foreach b_att b_latl
					(setq b_latt (cons (|O|ITEM 1 b_att) b_latt))
				)
				(setq b_latt (reverse b_latt))
			)
			((>= b_catv b_catn)
				(setq b_pobj b_obj)
				(repeat b_catn
					(setq b_pobj (entnext b_pobj) b_attl (entget b_pobj) 
						b_latt (cons (|O|ITEM 1 b_attl) b_latt)
					)
				)
				(setq b_latt (reverse b_latt))
			)
		)
		(|B|INSERT b_nname b_pin b_lay b_angi b_efx b_efy b_efz b_latt)
		(entdel b_obj)
	)
	(|G|RESTVAR T)
)

;"|B|ROTABLK"
(defun |B|ROTAR (b_bln b_ang)
	(setq b_entp (entget b_bln) b_att (|O|ITEM 66 b_entp) b_inp (|O|ITEM 10 b_entp) b_a1 (|O|ITEM 50 b_entp) b_nan (+ b_ang b_a1)
	      b_entp (|O|REEMP 50 b_nan b_entp) b_nat b_bln)
	(entmod b_entp)
	(if (eq b_att 1)
		(while (not (eq (|O|ITEM 0 (entget (setq b_nat (entnext b_nat)))) "SEQEND"))
			(setq b_attl (entget b_nat) b_p1 (|O|ITEM 10 b_attl) b_p2 (|O|ITEM 11 b_attl) b_aat (|O|ITEM 50 b_attl)
				b_np1 (|K|POLAR b_inp (+ (|K|ANG b_inp b_p1) b_ang) (|K|DISTH b_inp b_p1))
				b_np2 (|K|POLAR b_inp (+ (|K|ANG b_inp b_p2) b_ang) (|K|DISTH b_inp b_p2))
				b_aat (+ b_aat b_ang)
				b_attl (|O|REEMP 10 b_np1 b_attl)
				b_attl (|O|REEMP 11 b_np2 b_attl)
				b_attl (|O|REEMP 50 b_aat b_attl)
			)
			(entmod b_attl)
		)
	)
	(entupd b_bln)
)

;"|B|ESC"
(defun |B|ESC (b_bln b_fs)
	(cond
		((listp b_fs)
			(setq b_xfs (car b_fs) b_yfs (cadr b_fs) b_zfs (cadr b_fs))
			(if (not b_zfs) (setq b_zfs 1.0))
		)
		(T (setq b_xfs b_fs b_yfs b_fs b_zfs b_fs))
	)
	(setq b_entp (entget b_bln) b_att (|O|ITEM 66 b_entp) b_inp (|O|ITEM 10 b_entp) b_fsx (|O|ITEM 41 b_entp) b_fsy (|O|ITEM 42 b_entp) b_fsz (|O|ITEM 43 b_entp)
		b_entp (|O|REEMP 41 (* b_xfs b_fsx) b_entp)
		b_entp (|O|REEMP 42 (* b_yfs b_fsy) b_entp)
		b_entp (|O|REEMP 43 (* b_zfs b_fsz) b_entp)
		b_nat b_bln
	)
	(if (eq b_att 1)
		(while (not (eq (|O|ITEM 0 (entget (setq b_nat (entnext b_nat)))) "SEQEND"))
			(setq b_attl (entget b_nat) b_p1 (|O|ITEM 10 b_attl) b_p2 (|O|ITEM 11 b_attl) b_aat (|O|ITEM 40 b_attl)
				b_np1 (|K|POLAR b_inp (|K|ANG b_inp b_p1) (* (|K|DISTH b_inp b_p1) b_fs))
				b_np2 (|K|POLAR b_inp (|K|ANG b_inp b_p2) (* (|K|DISTH b_inp b_p2) b_fs))
				b_aat (* b_aat b_fs)
				b_attl (|O|REEMP 10 b_np1 b_attl)
				b_attl (|O|REEMP 11 b_np2 b_attl)
				b_attl (|O|REEMP 40 b_aat b_attl)
			)
			(entmod b_attl)
		)
	)
	(entmod b_entp) (entupd b_bln)
)

;"|B|RBS"
(defun |B|RBS()
	(|G|SET0VAR)  
	(prompt "\nseleccione los atributos a desplazar, ")
	(setq b_ssloop (ssget '((-4 . "<AND") (0 . "INSERT") (-4 . "<OR") (2 . "RPT1") (2 . "RPT2") (2 . "RPT3") (2 . "RPT4") (2 . "CBE") (2 . "CBI") (2 . "CBES") (2 . "CBIS") (-4 . "OR>") (-4 . "AND>")))
		b_i 0 b_ang PI
	)
	(while (setq b_obj (ssname b_ssloop (- (setq b_i (1+ b_i)) 1)))
		(setq b_objl (entget b_obj) b_bname (|O|ITEM 2 b_objl)
			b_pin (|O|ITEM 10 b_objl)
			b_angi (+ (|O|ITEM b_objl) PI)
			b_efx (|O|ITEM 41 b_objl)
			b_efy (|O|ITEM 42 b_objl)
			b_efz (|O|ITEM 43 b_objl)
			b_lay (|O|ITEM 8 b_objl)
			b_attt (|B|ATTVAL b_obj 1)  
		)
		(cond ((eq b_bname "RPT1") (setq b_nname "RPT3"))
			((eq b_bname "RPT3") (setq b_nname "RPT1"))
			((eq b_bname "RPT2") (setq b_nname "RPT4"))
			((eq b_bname "RPT4") (setq b_nname "RPT2"))
			((eq b_bname "CBIS") (setq b_nname "CBES"))
			((eq b_bname "CBES") (setq b_nname "CBIS"))
			((eq b_bname "CBI") (setq b_nname "CBE" b_angi (- b_angi PI)))
			((eq b_bname "CBE") (setq b_nname "CBI" b_angi (- b_angi PI)))
		)
		(|B|INSERT b_nname b_pin b_lay b_angi (list b_efx b_efy b_efz) (list b_attt))
		(entdel b_obj)
	)
	(|G|RESTVAR T)
)

(defun c:dibescg ()
	(setq pix 0 piy 0 pin (list pix piy) les (list 1 2 2.5 5 7.5 10 20 25 50 75 100 200 250 500 750 1000 2000 2500 5000 7500 10000))
	(foreach eh les
		(foreach ev (reverse les)
			(if (= ev eh)
				(|B|ESCG pin eh nil "m")
				(|B|ESCG pin eh ev "m")
			)
			(setq pin (|K|Y+ pin 25))
		)
		(setq pin (|K|X+ (list (car pin) 0) 120))
	)
)