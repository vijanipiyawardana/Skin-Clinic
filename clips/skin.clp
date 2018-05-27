;;;======================================================
;;;           	 	   SKIN CARE EXPERT
;;;     	 Self Learning Decision Tree Program 
;;;					  (JESS application)
;;;					   jess version 7.1
;;;
;;;     This program tries to determine your skin type
;;;		and provide instructions to a healthier skin.
;;;    
;;;		~~~~~~	179413F	~~~~ A. V. S. Piyawardana  ~~~~~~ 
;;;     
;;;======================================================


(deftemplate question
	(slot text)
	(slot type)
	(slot ident)
)

(deftemplate answer
	(slot ident)
	(slot text)
)

(deftemplate recommendation 
	(slot skintype)
	(slot instructions)
)

(deftemplate reason
	(slot skintype)
	(slot details)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;							
;;;;;;;;;;;;; OPERATES ON SPECIFIC AREA 
;;;;;;;;;;;;;							
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule startup)

(defrule print-banner
=> 
	(printout t "Type your name and press Enter> ")
	(bind ?name (read))
	(printout t crlf "********************" crlf)
	(printout t "Hello, " ?name "." crlf)
	(printout t "Welcome to the Skin Care Expert " crlf crlf)
	(printout t "Please answer the questions. " crlf)
	(printout t "I will tell you what type of skin you have " )
	(printout t "and some advices for a healthy skin." crlf)
	(printout t "*******************" crlf crlf)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deffunction is-of-type (?answer ?type)
	"Check that the answer has the right form"
	
	(if (eq ?type yes-no) then
		(return (or (eq ?answer yes) (eq ?answer no) ))
	else 
	(if (eq ?type number) then
		(return (numberp ?answer) )
	
	else 
		(return (> (str-length ?answer) 0) )
	)
	)
)

(deffunction ask-user (?question ?type)
	"Ask a question, and return the answer"
	(bind ?answer "")
	(while (not (is-of-type ?answer ?type)) do
		(printout t ?question " ")
		(if (eq ?type yes-no) then
			(printout t "(yes or no) "))
		(bind ?answer (read)))
	(return ?answer)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;								 
;;;;;;;;;;;;; PROCESS INCOMPLETE INFORMATION 
;;;;;;;;;;;;; AVOID MISTAKES 				 
;;;;;;;;;;;;;								 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defmodule ask)

(defrule ask::ask-question-by-id
	"Ask a question and assert the answer"
	(declare (auto-focus TRUE))
	; If there is a question with ident ?id...
	(MAIN::question (ident ?id) (text ?text) (type ?type))
	; ... and there is no answer for it
	(not (MAIN::answer (ident ?id)))
	; ... and the trigger fact for this question exists
	?ask <- (MAIN::ask ?id)
	=>
	; Ask the question
	(bind ?answer (ask-user ?text ?type))
	; Assert the answer as a fact
	(assert (MAIN::answer (ident ?id) (text ?answer)))
	; Remove the trigger
	(retract ?ask)
	; And finally, exit this module
	(return)
	
	
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deffacts question-data

	"The question the system can ask"
	
	(question (ident pimples) (type yes-no)
		(text "Do you have pimples on your skin?"))
	(question (ident shine) (type yes-no)
		(text "Do you have a glossy shine on your skin?"))
	(question (ident pores) (type yes-no)
		(text "Do you have pores on your skin?"))
	(question (ident large-pores) (type yes-no)
		(text "Are the pores enlarged and clearly visible?"))
		
	(question (ident ashy) (type yes-no)
		(text "Do you have gray or ashy skin?"))
	(question (ident itching) (type yes-no)
		(text "Do you have frequent itchiness on your skin?"))
	(question (ident crack) (type yes-no)
		(text "Do you have cracks on the skin which may bleed?"))
	(question (ident cracked-lips) (type yes-no)
		(text "Do you have cracked lips, palms or heels?"))
	(question (ident rough) (type yes-no)
		(text "Do you feel roughness in your skin?"))
	(question (ident soft) (type yes-no)
		(text "Do you have soft and smooth skin?"))
		
	(question (ident callus) (type yes-no)
		(text "Do you have calluses on your feet or palm?"))
	
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;							
;;;;;;;;;;;;;	 ASK QUESTIONS 			
;;;;;;;;;;;;;							
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defmodule interview)

(defrule request-soft
=> 
	(assert (ask soft)))

(defrule request-shine
=> 
	(assert (ask shine)))

(defrule request-pimples
=>
	(assert (ask pimples)))

(defrule request-pores
=> 
	(assert (ask pores)))

(defrule request-enlarged-pores
;	If there are pores...
	(answer (ident pores) (text ?t&:(eq ?t yes)))
	=>
	(assert (ask large-pores))
)


(defrule request-rough
=>
	(assert (ask rough)))

(defrule request-callus
	(answer (ident rough) (text ?t&:(eq ?t yes)))
	=>
	(assert (ask callus))
)

(defrule request-ashy
=>
	(assert (ask ashy)))
	
(defrule request-itching
=>
	(assert (ask itching)))
	
(defrule request-cracks
	(answer (ident ashy) (text ?t&:(eq ?t yes)))
	(answer (ident itching) (text ?t&:(eq ?t yes)))
	=> 
	(assert (ask crack))
)

(defrule request-cracked-lips
	(answer (ident callus) (text ?t&:(eq ?t yes)))
	(answer (ident crack) (text ?t&:(eq ?t yes)))
	=> 
	(assert (ask cracked-lips))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;; FORWARD CHAINING RULES (ALSO BACKWARD CHAINING)		
;;;;;;;;;;;;; USES HEURISTICS 		 		
;;;;;;;;;;;;; PROVIDE ALTERNATIVE SOLUTIONS 
;;;;;;;;;;;;; UNCERTAINTY HANDLING 			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defmodule recommend)

(defrule normal-skin-1

	(answer (ident soft) (text yes))
	(answer (ident pimples) (text no))
	(answer (ident itching) (text no))
	=>
	(bind ?in "You have healthy skin. Get a balanced diet and keep your skin clean.")
	(assert (recommendation (skintype Normal) (instructions ?in)))
)

(defrule normal-skin-2

	(answer (ident soft) (text yes))
	(answer (ident shine) (text yes))
	(answer (ident pimples) (text no))
	(answer (ident itching) (text no))
	=>
	(bind ?in "You have healthy skin. Get a balanced diet and keep your skin clean.")
	(assert (recommendation (skintype Normal) (instructions ?in)))
)

(defrule normal-skin-3

	(answer (ident shine) (text yes))
	(answer (ident pores) (text yes))
	(answer (ident itching) (text no))
	=>
	(bind ?in "You have healthy skin. Get a balanced diet and keep your skin clean.")
	(assert (recommendation (skintype Normal) (instructions ?in)))
)

(defrule oily-skin-1

	(answer (ident shine) (text yes))
	(answer (ident pimples) (text yes))
	(answer (ident large-pores) (text yes))
	=>
	(bind ?in "Wash your face and body twice a day. Use an oil free, water based moisturizers. Scrub to avoid dead skin cells and pores.")
	(assert (recommendation (skintype Oily)	(instructions ?in)))
)

(defrule oily-skin-2

	(answer (ident pimples) (text yes))
	(answer (ident pores) (text yes))
	=>
	(bind ?in "Wash your face and body twice a day. Use an oil free, water based moisturizers. Scrub to avoid dead skin cells and pores.")
	(assert (recommendation (skintype Oily)	(instructions ?in)))
)

(defrule dry-skin-1

	(answer (ident pimples) (text no))
	(answer (ident itching) (text yes))
	=>
	(bind ?in "Apply moisturizing cream. Drink a lot of water an juices.")
	(assert (recommendation (skintype Dry) (instructions ?in)))
	
)

(defrule dry-skin-2

	(answer (ident ashy) (text yes))
	(answer (ident itching) (text yes))
	(answer (ident crack) (text yes))
	=>
	(bind ?in "Apply moisturizing cream. Drink a lot of water an juices.")
	(assert (recommendation (skintype Dry) (instructions ?in)))
	
)

(defrule dry-skin-3

	(answer (ident rough) (text yes))
	(answer (ident ashy) (text yes))
	(answer (ident itching) (text yes))
	(answer (ident crack) (text yes))
	=>
	(bind ?in "Apply moisturizing cream. Drink a lot of water an juices.")
	(assert (recommendation (skintype Dry) (instructions ?in)))
	
)

(defrule extra-dry-skin

	(answer (ident callus) (text yes))
	(answer (ident cracked-lips) (text yes))
	=>
	(bind ?in "Apply moisturizing cream with vitamin E and use lip balm daily. Drink a lot of water. Wear well fitting comfortable shoes.")
	(assert (recommendation (skintype ExtraDry)	(instructions ?in)) )
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;											   
;;;;;;;;;;; PROVIDE RECOMMENDATIONS THAN EXACT ANSWERS 
;;;;;;;;;;;											   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defmodule report)

(defrule sort-and-print
	(recommendation (skintype ?s) (instructions ?i))
	=>
	(printout t crlf crlf)
	(printout t "Your skin type is " ?s crlf)
	(printout t "Instructions: " ?i crlf crlf)
	;(assert (reason (skintype ?s)))
	(give-reason ?s)
)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;									
;;;;;;; 	GIVING REASONS FOR ANSWERS	
;;;;;;;									
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(deffunction give-reason (?sk)
	
	(if (eq ?sk Normal) then
		(printout t "Reasons : your skin is soft and smooth even it looks shiny. It may have one or two pores due to climate changes." crlf)
	else 
	(if (eq ?sk Dry) then
		(printout t "Reasons : your skin is rough, and it may look ashy and sometimes have cracks due to frequent itching." crlf)
	else 
	(if (eq ?sk ExtraDry) then
		(printout t "Reasons : you have cracked lips, palms or heels, you have callus too." crlf)
	
	else 
		(printout t "Reasons : your skin is shiny also have pimples and small or large pores." crlf)
	)
	)
	)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
