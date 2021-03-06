;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ch 1.3 차수 높은 프로시저(higher-order procedure)로 요약하는 방법
;;; p72

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p72
;;; 아래와 같이 요약 가능하다는 것을 확인했다.
(define (cube x) (* x x x))

;;; 위는 정의하지 않고 아래와 같이 사용할 수 있다.

(* 3 3 3)
(* x x x)
(* y y y)

;;; 그러나 이는 비효율적이다. 또한 이름을 할당해 요약하는게 좋다.(추상화) 이를 higer-order procedure(차수 높은 프로시저)라 한다.

;;;;=================================<ch 1.3.1>=================================
;;; 프로시저를 인자로 받는 프로시저
;;; p73

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p73
;;; 세가지 절차가 있다.
(define (sum-integers a b)
  (if (> a b)
      0
      (+ a (sum-integers (+ a 1) b))))
;;; a부터 b까지 정수의 합

(define (sum-cubes a b)
  (if (> a b)
      0
      (+ (cube a) (sum-cubes (+ a 1) b))))
;;; a부터 b의 세제곱의 합

(define (pi-sum a b)
  (if (> a b)
      0
      (+ (/ 1.0 (* a (+ a 2))) (pi-sum (+ a 4) b))))

;;; pi/8 에 수렴하는 식이다.
;;; 라이프니쯔가 고안한 아래식에 의함
(pi/4) = 1 - (1/3) + (1/5) - (1/7) + ...

;;; 아래와 같이 기본 패턴 공유가 가능하다.

;;;->
;; (define (<name> a b)
;;   (if (> a b)
;;       0
;;       (+ (<term> a)
;; 	 (<name> (<next a) b))))

;;; 추상화(요약)이 이를 보여준다. 수학자들은 시그마(Σ)를 사용했다.

;;; 수학자와 마찬가지로 절차적 언어로 유사하게 디자인 가능하다.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p75~76

;;;----
(define (cube x) (* x x x))
;;;----

(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
	 (sum term (next a) next b))))
;;sum-cubes를 sum을 이용해 재정의
(define (inc n) (+ n 1))
(define (sum-cubes a b)
  (sum cube a inc b))

(sum-cubes 1 10)
;;->3025

;;;  1부터 10까지의 정수의 합도 위를 이용할 수 있다.
(define (identity x) x)
(define (sum-integers a b)
  (sum identity a inc b))

(sum-integers 1 10)

;;; pi-sum으로  pi의 근사값을 계산할 수 있다.

(define (pi-sum a b)
  (define (pi-term x)
    (/ 1.0 (* x (+ x 2))))
  (define (pi-next x)
    (+ x 4))
  (sum pi-term a pi-next b))

(* 8 (pi-sum 1 1000))

;;; 적분을 아래와 같이 적용 가능하다.
(define (integral f a b dx)
  (define (add-dx x) (+ x dx))
  (* (sum f (+ a (/ dx 2.0)) add-dx b)
     dx))
;;; 정확한 같은 0과 1 사이의 1/4를 세제곱한 값이다.
(integral cube 0 1 0.01)
(integral cube 0 1 0.001)
(integral cube 0 1 0.0001)
(integral cube 0 1 0.00001)
(integral cube 0 1 0.000001)

;;;; sine 함수 적분 테스트
(integral sin 0 (/ 3.14159 2) 0.001)

(integral identity 0 1 0.001)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 가우시안 함수 적분 테스트

;;;----
(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
	 (sum term (next a) next b))))

(define (integral f a b dx)
  (define (add-dx x) (+ x dx))
  (* (sum f (+ a (/ dx 2.0)) add-dx b)
     dx))
;;;----

(define (gaussian m sigma x)
  (define PI 3.14159)
  (define EXP 2.7183)
  (/ (expt EXP (/ (- (square (- x m)) ) (* 2 (square sigma)))) (sqrt (* 2 PI (square sigma)))))

;;; 1-D Gaussian function generator
(define (gen-gaussian m sigma)
  (let ((PI 3.14159)
	(E 2.7183))
    (lambda (x)
      (/ (expt E 
	       (/ (- (expt (- x m) 2)) (* 2 (expt sigma 2))))
	 (sqrt (* 2 PI (expt sigma 2)))))))

(define gaussian-f (gen-gaussian 0 1))

(integral gaussian-f -100 100 0.01)




;;;--------------------------< ex 1.29 >--------------------------
;;; p77

;;; 앞의 방식으로 cube 정적분
;;;----
(define (cube x) (* x x x))

(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
	 (sum term (next a) next b))))

(define (integral f a b dx)
  (define (add-dx x) (+ x dx))
  (* (sum f (+ a (/ dx 2.0)) add-dx b)
     dx))

(integral cube 0 1 0.01)
;;;----




;;; Simpson 방법으로 cube 정적분
;; h/3 [ y0 + 4y1 + 2y2 + 4y3 + 2y4 + ... + 2yn-2 + 4yn-1 + yn]
;; => h/3 [ [y0 + yn] +
;;          4[y1 + y3 + ... + yn-3 + yn-1] +
;;          2[y2 + y4 + ... + yn-2 + yn] ]

(define (inc2 n)
  (+ n 2))

(define (integral-simpson f a b n)
  (define h (/ (- b a) n))
  (define (yk k)
    (f (+ a (* k h))))
  (* (/ h 3)
	(+ (yk 0)
	   (yk n)
	   (* 4 (sum yk 1 inc2 (- n 1)))
	   (* 2 (sum yk 2 inc2 n)))))

(integral-simpson cube 0 1.0 100)
(integral-simpson cube 0 1.0 1000)
(integral-simpson cube 0 1.0 10000)
(integral-simpson cube 0 1.0 100000)
(integral-simpson cube 0 1.0 1000000)
;; 원래 0.25 임 

(integral cube 0 1 0.01)
(integral cube 0 1 0.001)
(integral cube 0 1 0.0001)
(integral cube 0 1 0.00001)
(integral cube 0 1 0.000001)
;; 원래 0.25 임.

(integral-simpson gaussian-f -100 100 100)
(integral-simpson gaussian-f -100 100 1000)
(integral-simpson gaussian-f -100 100 10000)
(integral-simpson gaussian-f -100 100 100000)
;; 원래 거의 1임




;;;--------------------------< ex 1.30 >--------------------------
;;; p77
;;; sum의 선형재귀프로세스(linear recursion process) 

;; (define (sum term a next b)
;;   (define (iter a result)
;;     (if <>
;; 	<>
;; 	(iter <> <>)))
;;   (iter <> <>))


(define (sum-iter term a next b)
  (define (iter a result)
    (if (> a b)
	result
	(iter (next a) (+ result (term a)))))
  (iter a 0))

;;;----
(define (inc n)
  (+ n 1))
;;;----

(sum-iter identity 1 inc 10)

;;;------
(define (integral-iter f a b dx)
  (define (add-dx x) (+ x dx))
  (* (sum-iter f (+ a (/ dx 2.0)) add-dx b)
     dx))


(integral cube 0 1 0.01)
(integral cube 0 1 0.001)
(integral cube 0 1 0.0001)
(integral cube 0 1 0.00001)
(integral cube 0 1 0.000001)
;; 원래 0.25 임.


(integral-iter cube 0 1 0.01)
(integral-iter cube 0 1 0.001)
(integral-iter cube 0 1 0.0001)
(integral-iter cube 0 1 0.00001)
(integral-iter cube 0 1 0.000001)
;; 원래 0.25 임.

;;;------



;;;--------------------------< ex 1.31 >--------------------------
;;; p78

(define (product term a next b)
  (if (> a b)
      1
      (* (term a)
	 (product term (next a) next b))))


(define (product-iter term a next b)
  (define (iter a result)
    (if (> a b)
	result
	(iter (next a) (* result (term a)))))
  (iter a 1))

;;;-----
(define (inc2 n)
  (+ n 2))
;;;-----

;; pi/4 = 2/3 * 4/3 * 4/5 * 6/5 * 6/7 * 8/7 ...
;;  =>  2/3 * 4/5 * 6/7 * ...
;;    * 4/3 * 6/5 * 8/7 * ...

;;; 되도는 product 이용
(define (find-pi b)
  (define (term1 x)
    (/ x (+ x 1)))
  (define (term2 x)
    (/ (+ x 2) (+ x 1)))
  (* (product term1 2 inc2 b)
     (product term2 2 inc2 b)
     4.0))


(find-pi 10)
(find-pi 100)
(find-pi 1000)
(find-pi 10000)
(find-pi 100000) ; 시간 너무 많이 걸림.

;;;----------------------------
;;; 반복 product 이용
(define (find-pi2 b)
  (define (term1 x)
    (/ x (+ x 1)))
  (define (term2 x)
    (/ (+ x 2) (+ x 1)))
  (* (product-iter term1 2 inc2 b)
     (product-iter term2 2 inc2 b)
     4.0))


(find-pi2 10)
(find-pi2 100)
(find-pi2 1000)
(find-pi2 10000)
(find-pi2 100000)



;;;--------------------------< ex 1.32 >--------------------------
;;; p78

;;;-------
(define (inc n) (+ n 1))

(define (product term a next b)
  (if (> a b)
      1
      (* (term a)
	 (product term (next a) next b))))

(define (sum term a next b)
  (if (> a b)
      0
      (+ (term a)
	 (sum term (next a) next b))))
;;;-------



;;; 되도는 accumulate
(define (accumulate combiner null-value term a next b)
  (if (> a b)
      null-value
      (combiner (term a)
		(accumulate combiner null-value term (next a) next b))))


(define (sum-acc term a next b)
  (accumulate + 0 term a next b))

(sum identity 1 inc 10)
(sum-acc identity 1 inc 10)


(define (product-acc term a next b)
  (accumulate * 1 term a next b))

(product identity 1 inc 10)
(product-acc identity 1 inc 10)



;;; 반복 accumulate
(define (accumulate-iter combiner null-value term a next b)
  (define (iter a result)
    (if (> a b)
	result
	(iter (next a) 
	      (combiner result (term a)))))
  (iter a null-value))


(define (sum-acc-iter term a next b)
  (accumulate-iter + 0 term a next b))

(sum identity 1 inc 10)
(sum-acc identity 1 inc 10)
(sum-acc-iter identity 1 inc 10)


(define (product-acc-iter term a next b)
  (accumulate-iter * 1 term a next b))

(product identity 1 inc 10)
(product-acc identity 1 inc 10)
(product-acc-iter identity 1 inc 10)




;;;--------------------------< ex 1.33 >--------------------------
;;; p79

;;; 되도는 filtered-accumulate
(define (filtered-accumulate predicator combiner null-value term a next b)
  (if (> a b)
      null-value
      (if (predicator a)
	  (combiner (term a)
		    (filtered-accumulate predicator
					 combiner 
					 null-value term (next a) next b))
	  (combiner null-value
		    (filtered-accumulate predicator
					 combiner 
					 null-value term (next a) next b)))))
;;; 반복 filtered-accumulate
(define (filtered-accumulate-iter predicator combiner null-value term a next b)
  (define (iter a result)
    (if (> a b)
	result
	(if (predicator a)
	    (iter (next a) (combiner result (term a)))
	    (iter (next a) result))))
  (iter a null-value))

;;;----
(define (square x)
  (* x x))
;;;----

(define (sum-of-prime a b)
  (filtered-accumulate prime? + 0 identity a inc b))

(sum-of-prime 1 10)  ; 1은 소수가 아니다.
(+ 2 3 5 7)

;;; a------------------------------------------
(define (sum-of-square-prime a b)
  (filtered-accumulate prime? + 0 square a inc b))

(define (sum-of-square-prime-iter a b)
  (filtered-accumulate-iter prime? + 0 square a inc b))

(sum-of-square-prime 2 10)
(sum-of-square-prime-iter 2 10)
(+ (* 2 2) (* 3 3) (* 5 5) (* 7 7)) 


;;; b------------------------------------------
(define (product-of-relative-prime a b)
  (define (relative-prime? i)
    (if (= (gcd i b) 1)
	#t
	#f))
  (filtered-accumulate relative-prime? * 1 identity a inc b))

(define (product-of-relative-prime-iter a b)
  (define (relative-prime? i)
    (if (= (gcd i b) 1)
	#t
	#f))
  (filtered-accumulate-iter relative-prime? * 1 identity a inc b))

(product-of-relative-prime 1 15)
(product-of-relative-prime-iter 1 15)
;;; relative primes to 15.
;;; 2 4 7 8 11 13 14
(* 2 4 7 8 11 13 14)

;;; for test
(define (test-relative-prime? i b)
  (define (relative-prime? i)
    (if (= (gcd i b) 1)
	#t
	#f))
  (relative-prime? i))

(test-relative-prime? 2 15) ;t
(test-relative-prime? 3 15)
(test-relative-prime? 4 15) ;t
(test-relative-prime? 5 15)
(test-relative-prime? 6 15)
(test-relative-prime? 7 15) ;t
(test-relative-prime? 8 15) ;t
(test-relative-prime? 9 15)
(test-relative-prime? 10 15)
(test-relative-prime? 11 15) ;t
(test-relative-prime? 12 15)
(test-relative-prime? 13 15) ;t
(test-relative-prime? 14 15) ;t


;;;-----------
(define (gcd a b)
  (if (= b 0)
      a
      (gcd b (remainder a b))))
;----
(define (square x)
  (* x x))

(define (smallest-divisor n)
  (find-divisor n 2))

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
	((divides? test-divisor n) test-divisor)
	(else (find-divisor n (+ test-divisor 1)))))

(define (divides? a b)
  (= (remainder b a) 0))

(define (prime? n)
  (if (<= n 1)
      #f      ; 1은 소수가 아니다.
      (= n (smallest-divisor n))))
;;;------------





;;;;=================================<ch 1.3.2>=================================
;;; lambda로 나타내는 프로시저
;;; p79

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p80
;;; 람다를 사용하여 더 편리하게 정의할 수 있다.

(lambda (x) (+ x 4))

(lambda (x) (/ 1.0 (* x (+ x 2))))

;;; 위를 이용해 아래과 같이 변경 가능

(define (pi-sum a b)
  (sum (lambda (x) (/ 1.0 (* x (+ x 2))))
       a
       (lambda (x) (+ x 4))
       b))

(pi-sum 1 10)

;;; 프로시저에 이름이 필요하지 않다.
(lambda (<formal-parameters>) <body>)

(define (integral f a b dx)
  (* (sum f
	  (+ a (/ dx 2.0))
	  (lambda (x) (+ x dx))
	  b)
     dx))

(integral (lambda (x) x) 0 1 0.01)

;;; 아래 둘은 같은 것이다.
(define (plus4 x) (+ x 4))

(define plus4 (lambda (x) (+ x 4)))

(lambda             (x)             (+    x     4))  the procedure   of an argument x  that adds  x and 4
;;; x와 4의 합을 인자 x의 프로시저로 표현할 수 있다.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p81

;; 프로시저 이름이 들어갈 수 있는 모든 자리에 lambda 식을 써도 좋다

((lambda (x y z) (+ x y (square z))) 1 2 3)




;;;;------------------------------------------------------------------
;;; let으로 갖힌 변수 만들기
;;; 지역 변수를 만들기 위해 let을 사용하자

;;; x뿐만 아니라 y도 a와 b와 같은 양으로 즉시 이름을 포함한다. 지역변수를 바인드하는 보조 프로시저를 사용해 달성할 수 있다. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p82
(define (f x y)
  (define (f-helper a b)
    (+ (* x (square a))
       (* y b)
       (* a b)))
  (f-helper (+ 1 (* x y))
	    (- 1 y)))

(f 3 4)
;;; 바인딩된 지역 변수를 위해 익명 프로시저를 저의한 람다 표현식을 사용가능하다.
;;; f의 바디는 프로시저를 호충하는 단일 폼이다.
;;=> lambda 식으로
(define (f x y)
  ((lambda (a b)
    (+ (* x (square a))
       (* y b)
       (* a b)))
   (+ 1 (* x y))
   (- 1 y)))

(f 3 4)

;;; 이 구조는 더 효율적으로 let을 호출하는 스페셜 폼이 유용하다.

;;=> let을 써서
(define (f x y)
  (let ((a (+ 1 (* x y)))
	(b (- 1 y)))
    (+ (* x (square a))
       (* y b)
       (* a b))))

(f 3 4)

;;; let의 일반형
;;; (let ((<var1> <exp1>)       (<var2> <exp2>)       (<varn> <expn>))    <body>)

;;; let 표현의 첫번째 부분은 이름 표현쌍의 리스트이다. let의 바디는 지역 변수로 바인드된 이름들로 평가된다.

((lambda (<var1> ...<varn>)     <body>)  <exp1>  <expn>)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p83

;;; let식은 lambda 식을 더 편하게 쓰려고 만든 달콤한 문법일 뿐이다.

;;; let은 그들이 사용되는 곳에서 지역적으로 변수를 바인드 한다.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p84

;;; x는 해당 표현에서만 5이다.

(let ((x 5))
  (+ (let ((x 3))
       (+ x (* x 10)))
     x))

;;; let의 바디에서 x는 사이고, let 표현은 33이다. 반면 x는 두번째에서 여전히 5이다.

(let ((x 3)
	(y (+ x 2)))
	(* x y))

;;; define으로 안쪽에서 이름을 정의하여 let처럼 쓸 수 있다.
;;; 하지만 이 책에서는 앞으로 define은 안쪽에서 프로시저를 정의할 때에만 쓰기로 한다.

(define (f x y)
  (define a (+ 1 (* x y)))
  (define b (- 1 y))
  (+ (* x (square a))
     (* y b)
     (* a b)))

(f 3 4)



;;;--------------------------< ex 1.34 >--------------------------
;;; p85

;;;---
(define (square x)
  (* x x))
;;;---

(define (f g)
  (g 2))

(f square)

(f (lambda (z) (* z (+ z 1))))

;;; 다음은 어떻게 되는가? 왜 그런가?
(f f)
;;-> (f 2)
;;->Error: 2 is not a function
;; f에 숫자 2를 적용하는 방법이 정의되어 있지 않다.




;;;;=================================<ch 1.3.3>=================================
;;; 일반적인 방법을 표현하는 프로시저
;;; p85
;;;고차원 프로시저를 조금 더 일반화 시키고 추상화하는 방법
;;;;------------------------------------------------------------------
;;; 이분법으로 방정식의 근 찾기

;;; p86

(define (average a b)
  (/ (+ a b) 2))

(define (search f neg-point pos-point)
  (let ((midpoint (average neg-point pos-point)))
    (if (close-enough? neg-point pos-point)
	midpoint
	(let ((test-value (f midpoint)))
	  (cond ((positive? test-value)
		 (search f neg-point midpoint))
		((negative? test-value)
		 (search f midpoint pos-point))
		(else midpoint))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p86
(define (close-enough? x y)
  (< (abs (- x y)) 0.001))

(define (half-interval-method f a b)
  (let ((a-value (f a))
	(b-value (f b)))
    (cond ((and (negative? a-value) (positive? b-value))
	   (search f a b))
	  ((and (negative? b-value) (positive? a-value))
	   (search f b a))
	  (else
	   (error "Values are not of opposite" a b)))))

;;; sin(x) =0 의 근 찾기
(half-interval-method sin 2.0 4.0)

;;; x^3 - 2x - 3 = 0 의 실근
(half-interval-method (lambda (x) (- (* x x x) (* 2 x) 3))
		      1.0
		      2.0)



;;;;------------------------------------------------------------------
;;; 함수의 고정점 찾기
;;; p88
;;; f(x) = x 가 참이면 x를 f의 고정점(fixed point)라 한다.
;;; 특정 함수에서 f는 f를 반복적으로 적용하고 초기 기대값으로 시작하여 고정점에 이를 수 있다.

;;; 이 아이디어로 함수의 고정점을 근사하는 것을 만들고 기대값을 초기화 하여 함수의 입력 값을 얻을 수 있다.
 ;;; 오차범위보다 작게 차이의 값을 반복해 함수를 적용해 찾을 수 있으며 오래 걸리지 않는다.
(define tolerance 0.00001)

(define (fixed-point f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (if (close-enough? guess next)
	  next
	  (try next))))
  (try first-guess))

;;; 이 메소드를  이용해 코사인 함수의 초기 근사를 1로 지정해 찾을 수 있다.

(fixed-point cos 1.0)

;;;'주57; 고정점을 얻을 때까지 라디안 모드에서 반복해 cos을 누른다. 지루할 때 해보세요.
;;; 0.73908513321516064165531208767387
;;; p88

;;; 마찬가지로 y=siny+ cosy의 답을 찾을 수 있다.

(fixed-point (lambda (y) (+ (sin y) (cos y)))
	     1.0)


;;; x의 제곱근은 y^2=x 라는 조건에 맞는 y를 찾는 문제이다.
;;; -> y=x/y => y |-> x/y 함수의 고정점을 찾는 문제와 같다

(define (sqrt x)
  (fixed-point (lambda (y) (/ x y))
	       1.0))

(sqrt 2)
;;<- 답이 안나옴.

;;; 평균 내어 잠재우기(average damping)
(define (sqrt x)
  (fixed-point (lambda (y) (average y (/ x y)))
	       1.0))

(sqrt 2)


;;;--------------------------< ex 1.35 >--------------------------
;;; p90

;;; in p50
;;; phi = (1+sqrt(5))/2 =~ 1.6180

;;; phi^2 = phi + 1
;;; => phi = 1 + 1/phi
;;; => x |-> 1 + 1/x

(fixed-point (lambda (x) (+ 1 (/ 1 x))) 1.0)
;;-> 1.6180327868852458



;;;--------------------------< ex 1.36 >--------------------------
;;; p90

;;;---
(define tolerance 0.00001)
;;;---

(define (fixed-point-display f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  (define (try guess)
    (let ((next (f guess)))
      (print guess)
      (newline)
      (if (close-enough? guess next)
	  next
	  (try next))))
  (try first-guess))

(fixed-point-display (lambda (x) (/ (log 1000) (log x)))
		     1.5)
;;;-> 4.555539351985717



;;;--------------------------< ex 1.37 >--------------------------
;;; p90,91

;;; 되돌기 프로세스(recursive process)
(define (cont-frac n d k)
  (define (jth-frac j)
    (if (= j k)
	(/ (n j) (d j))
	(/ (n j) (+ (d j) (jth-frac (+ j 1))))))
  (jth-frac 1))

;;; phi =~ (1 + (sqrt 5)) / 2 =~ 1.618033988749989
;;; 1/phi =~ 0.6180339887498588

(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 1)  ; 1.0
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 2)  ; 0.5
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 3)  ; 0.6666666666666666
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 4)  ; 0.6000000000000001
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 5)  ; 0.625
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 10)  ; 0.6179775280898876
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 15)  ; 0.6180344478216819
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 20)  ; 0.6180339850173578
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 30)  ; 0.6180339887496482
(cont-frac (lambda (i) 1.0) (lambda (i) 1.0) 50)  ; 0.6180339887498948

;;; test 
(cont-frac (lambda (i) 1.0) (lambda (i) 2.0) 3)  ; (/ 1. (+ 2 (/ 1 (+ 2 (/ 1 2)))))



;;; 반복 프로세스(iterative process)
(define (cont-frac-iter n d k)
  (define (frac-inner j acc-frac)
    (if (> j 2)
	(frac-inner (- j 1)
		     (/ (n (- j 1))
			(+ (d (- j 1)) acc-frac)))
	(/ (n 1) (+ (d 1) acc-frac))))
  (if (= k 1)
      (/ (n 1) (d 1))
      (frac-inner k (/ (n k) (d k)))))

(/ 1. (+ 1 (/ 1 (+ 1 (/ 1 1)))))  ; k:3
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 1)   ; 1.0
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 2)   ; 0.5
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 3)   ; 0.6666666666666666
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 4)   ; 0.6000000000000001
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 5)   ; 0.625
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 10)  ; 0.6179775280898876
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 15)  ; 0.6180344478216819
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 20)  ; 0.6180339850173578
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 30)  ; 0.6180339887496482
(cont-frac-iter (lambda (i) 1.0) (lambda (i) 1.0) 50)  ; 0.6180339887498948



;;;--------------------------< ex 1.38 >--------------------------
;;; p91,92

;; 1/
;;   (1 + 1/
;;     (2 + 1/
;;       (1 + 1/
;;         (1 + 1/
;;           (4 + 1/
;;             (1 + 1/
;;                ...
;;                       ))))))

;; j mod 3
;; ->   1 2 0
;; -----------
;; dj : 1 2 1     (j: 1  2  3)
;;      1 4 1     (   4  5  6)
;;      1 6 1     (   7  8  9)
;;      1 8 1 ... (  10 11 12)
;;        ^
;;        | : (j + 1) / 3 * 2

(define (cont-frac-euler k)
  (define (d-euler j)
    (let ((rem (remainder j 3)))
      (cond ((= rem 0) 1.0)
	    ((= rem 1) 1.0)
	    (else (* (/ (+ j 1.) 3.) 2.0)))))
  (cont-frac-iter (lambda (i) 1.0) d-euler k))


;; e =~ 2.718281828459045
;; <- (exp 1)
;; e-2 =~ 0.718281828459045
(cont-frac-euler 1) ; 1.0                  ; (/ 1. 1)
(cont-frac-euler 2) ; 0.6666666666666666   ; (/ 1. (+ 1 (/ 1 2)))
(cont-frac-euler 3) ; 0.75                 ; (/ 1. (+ 1 (/ 1 (+ 2 (/ 1 1)))))
(cont-frac-euler 4) ; 0.7142857142857143
(cont-frac-euler 5) ; 0.71875 ; (/ 1. (+ 1 (/ 1 (+ 2 (/ 1 (+ 1 (/ 1 (+ 1 (/ 1 4)))))))))
(cont-frac-euler 6) ; 0.717948717948718
(cont-frac-euler 10)
(cont-frac-euler 20) ; 0.7182818284590452
(cont-frac-euler 30) ; 0.7182818284590453
(cont-frac-euler 40) ; 0.7182818284590453
(cont-frac-euler 50) ; 0.7182818284590453

;(/ 1. (+ 1 (/ 1 (+ 2 (/ 1 (+ 1 (/ 1 (+ 1 (/ 1 (+ 4 (/ 1 (+ 1 (/ 1 (+ 1 (/ 1 (+ 6 (/ 1 (+ 1 (/ 1 (+ 1 (/ 1 (+ 8 (/ 1 1)))))))))))))))))))))))
;-> 0.7182818229439497


;;;--------------------------< ex 1.39 >--------------------------
;;; p92

;;; 되돌기 프로세스(recursive process)
(define (tan-cf x k)
  (define (n i)
    (square i))
  (define (d i)
    (+ (* (- i 1) 2) 1))
  (define (tan-cf-rec n d k)
    (define (jth-frac j)
      (if (= j k)
	  (/ (n x) (d j))
	  (/ (n x) (- (d j) (jth-frac (+ j 1))))))
    (jth-frac 2))
  (if (= k 1)
      (/ x (d 1))
      (/ x (- (d 1) (tan-cf-rec n d k)))))

(tan 1) ; 1.5574077246549023

(tan-cf 1. 1)  ; 1.0
(tan-cf 1. 2)  ; 1.4999999999999998
(tan-cf 1. 3)  ; 1.5555555555555558
(tan-cf 1. 4)  ; 1.5573770491803278
(tan-cf 1. 5)  ; 1.5574074074074076
(tan-cf 1. 10) ; 1.557407724654902
(tan-cf 1. 15) ; 1.557407724654902
(tan-cf 1. 20) ; 1.557407724654902

;;; 반복 프로세스
(define (tan-cf x k)
  (define (tan-cf-iter n1 n d k)
    (define (jth-tan-cf-inner j acc-frac)
      (if (> j 2)
	  (jth-tan-cf-inner (- j 1)
			    (/ (n x)
			       (- (d (- j 1)) acc-frac)))
	  (/ (n1 x) (- (d 1) acc-frac))))
    (if (= k 1)
	(/ (n x) (d 1))
	(jth-tan-cf-inner k (/ (n x) (d k)))))
  (tan-cf-iter (lambda (i) i) 
	       (lambda (i) (square i))
	       (lambda (i) (+ (* (- i 1) 2) 1))
	       k))

(tan 1) ; 1.5574077246549023

(tan-cf 1. 1)  ; 1.0
(tan-cf 1. 2)  ; 1.4999999999999998
(tan-cf 1. 3)  ; 1.5555555555555558
(tan-cf 1. 4)  ; 1.5573770491803278
(tan-cf 1. 5)  ; 1.5574074074074076
(tan-cf 1. 10) ; 1.557407724654902
(tan-cf 1. 15) ; 1.557407724654902
(tan-cf 1. 20) ; 1.557407724654902


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 아래와 같은 형태를 갖는 연속분수 계산함수를 만들어내는 함수
; n1(x) /
;        C( d(1) , n(x) /
;                         C( d(2) , n(x) / 
;                                         ...
;                                         C( d(k-1) , n(x) / d(k)

;;; 반복 프로세스(iterative process)
(define (cf-general-iter combiner n1 n d)
  (lambda (x k)
    (define (frac-inner j acc-frac)
      (if (> j 2)
	  (frac-inner (- j 1)
		      (/ (n x)
			 (combiner (d (- j 1)) acc-frac)))
	  (/ (n1 x) (combiner (d (- j 1)) acc-frac))))
    (if (= k 1)
	(/ (n x) (d 1))
	(frac-inner k (/ (n x) (d k))))))

(define tan-cf
  (cf-general-iter -
		   (lambda (i) i) 
		   (lambda (i) (square i))
		   (lambda (i) (+ (* (- i 1) 2) 1))))


(tan 1) ; 1.5574077246549023

(tan-cf 1. 1)  ; 1.0
(tan-cf 1. 2)  ; 1.4999999999999998
(tan-cf 1. 3)  ; 1.5555555555555558
(tan-cf 1. 4)  ; 1.5573770491803278
(tan-cf 1. 5)  ; 1.5574074074074076
(tan-cf 1. 10) ; 1.557407724654902
(tan-cf 1. 15) ; 1.557407724654902
(tan-cf 1. 20) ; 1.557407724654902





;;;;=================================<ch 1.3.4>=================================
;;; 프로시저를 만드는 프로시저
;;; p92

;;; 프로시저로부터 나오는 값으로 프로시저를 만드는 파워풀한 표현을 얻을 수 있다.fixed-point 예제에서 아이디어를 얻을 수 있다. 근사 수렴을 하기 위해 average damping을 사용한다. 함수 f는 우리는 x의 평균과 f(x)와 같아지는 x에서 값을 갖는 함수를 상정해 볼 수 있다.
;;; 아래 프로시저로 평균값에 의해 average damping의 아이디어를 표현할 수 있다.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p92

(define (average-damp f)
  (lambda (x) (average x (f x))))

;;; 평균 감쇄는 프로시저 f의 인자로 얻어진 프로시저이다. 그 값은 프로시저에 의해 리턴되고. (람다에 의해 생성)x가 적용될 때, x와 fx의 평균을 산출한다. 예를 들어 평균감쇄가 적용된 square 프로시저는 x와 x^2의 평균 수 x 를 값으로 가진다. 10번 적용된 10과 100의 평균은 55이다.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; p93

;;;---
(define (square x)
  (* x x))
;;;---

((average-damp square) 10)
;;55

(define (sqrt x)
  (fixed-point (average-damp (lambda (y) (/ x y)))
	       1.0))
;; 고정점 찾기,  평균 잦아들기, y|-> x/y  구조가 그대로 드러남

(sqrt 2)

;; 프로그래머는 여러 절차에서 적절한 식을 선택하여 재사용할 수 있어야 한다.
;;;;;;;;;;;;;;;;;;;;;;;
;;; p94

;;; y^3 = x
;;; y |-> x / y^2
(define (cube-root x)
  (fixed-point (average-damp (lambda (y) (/ x (square y))))
	       1.0))

(cube-root 8)



;;;;------------------------------------------------------------------
;;; 뉴튼방법
;;; p94

;;; x |-> g(x) 가 미분되는 함수이면,
;;; g(x) = 0 의 근은 함수 x |-> f(x) 의 정점과 같다.
;;; 이 때, f(x) = x - g(x)/Dg(x)

;;; Dg(x) = (g(x + dx) - g(x)) / dx

;;;;;;;;;;;;;;;;;;;;;
;;; p95
(define (deriv g)
  (lambda (x)
    (/ (- (g (+ x dx)) (g x))
       dx)))

(define dx 0.00001)

(define (cube x) (* x x x))

((deriv cube) 5)



;;;---
(define (square x)
  (* x x))
;;;---

(define (deriv g)
  (lambda (x)
    (/ (- (g (+ x dx)) (g x))
       dx)))

(define dx 0.00001)

(define (cube x) (* x x x))
((deriv cube) 5)
75.00014999664018

;;;; deriv를 써서 뉴턴 방법을 고정점 찾는 방법으로 표현
;;; f(x) = x - g(x)/Dg(x) 에 해당
(define (newton-transform g)
  (lambda (x)
    (- x (/ (g x) ((deriv g) x)))))

(define (newtons-method g guess)
  (fixed-point (newton-transform g) guess))

;;; 제곱근 : y |-> y^2 - x       <-- ???
;;; y^2 = x   =>  y^2 - x = 0   <-- g(x) = 0 이라서?

(define (sqrt x)
  (newtons-method (lambda (y) (- (square y) x))
		  1.0))

(sqrt 2)


;;; 세제곱근을 뉴튼 방법과 고정점 찾는 방법으로
;;; y^3 = x  =>  y^3 - x = 0    <-- g(x) = 0   
(define (cube-root x)
  (newtons-method (lambda (y) (- (cube y) x))
		  1.0))

(cube-root 8)




;;;;------------------------------------------------------------------
;;; 요약과 일등급 프로시저
;;; p96

(define (fixed-point-of-transform g transform guess)
  (fixed-point (transform g) guess))

(define (sqrt x)
  (fixed-point-of-transform (lambda (y) (/ x y))
			    average-damp
			    1.0))

(sqrt 2)
;-> 1.4142135623746899

(define (sqrt x)
  (fixed-point-of-transform (lambda (y) (- (square y) x))
			    newton-transform
			    1.0))

(sqrt 2)
;-> 1.4142135623822438

;;; 권리와 권한의 일급객체 요소는 아래와 같다.

;;; 실행 시간 중에 생성되고 서브루틴을 인자의 형태로 반환하는 엔티티를 가리킨다.

;;; They may be named by variables.

;;; 변수에 의해 명명되어야 한다.

;;; They may be passed as arguments to procedures.

;;; 프로시저로 인자로 전달되어야 한다.

;;; They may be returned as the results of procedures.

;;; 프로시저의 결과에 의해 반환된다.

;;; They may be included in data structures
;;; 데이터 구조들 내에 포함된다.
;;; LISP은 일급 객체 상태를 갖는다.
;;; 효율적인 구현을 위한 문제가 있지만, 결과는 좋다.


;;;--------------------------< ex 1.40 >--------------------------
;;; p98
(define (cubic a b c)
  (lambda (x)
    (+ (expt x 3)
       (* a (expt x 2))
       (* b x)
       c)))

;;; x^3 - 3x^2 + 3x -1 = (x - 1)^3 =0 
;;; => x = 1
(newtons-method (cubic -3 3 -1) 1)
;; => 1

;;; x^3 - 3x^2 + 2x + 0 = x(x - 1)(x - 2) = 0
;;; => x = 0, 1, 2
(newtons-method (cubic -3 2 0) 0.1) ;-> 6.373186586624513e-12
(newtons-method (cubic -3 2 0) 0.9) ;-> 0.9999999999999999
(newtons-method (cubic -3 2 0) 1.7) ;-> 2.000000000023838


;;;--------------------------< ex 1.41 >--------------------------
;;; p98
(define (double f)
  (lambda (x)
    (f (f x))))

;;;---
(define (inc x)
  (+ x 1))
;;;---

((double inc) 3) ;-> 5

(((double (double double)) inc) 5)  ;-> 21
;; double -> 2 번
;; (double double) -> 2 * 2 -> 4 번
;; (double (double double)) -> 4 * 4 -> 16 번
;; => inc를 16 번 수행 : +16


;;;--------------------------< ex 1.42 >--------------------------
;;; p99
(define (compose f g)
  (lambda (x)
    (f (g x))))

;;;---
(define (square x)
  (* x x))
;;;---

((compose square inc) 6)
;; (square (inc 6)) -> (square 7) -> 49

;;;--------------------------< ex 1.43 >--------------------------
;;; p99
(define (repeated f n)
  (if (= n 1)
      f
      (repeated (compose f f) (- n 1))))

((repeated square 2) 5)
;;; -> 625


;;;--------------------------< ex 1.44 >--------------------------
;;; p99
(define dx 0.1)

(define (smooth f)
  (lambda (x)
    (/ (+ (f (- x dx))
	  (f x)
	  (f (+ x dx)))
       3)))

;;; f :
;;;  ^
;;;1 | -----
;;;  | |   |
;;;---------------> x
;;;  0 1 2 3
(define (f x)
  (cond ((< x 1) 0)
	((> x 3) 0)
	(else 1)))
(f 0)   ; 0
(f 0.9) ; 0
(f 1)   ; 1
(f 1.1) ; 1
(f 2)   ; 1
(f 3)   ; 1

((smooth (lambda (x) (* x x))) 1)
;;; smooth f :
;;;  ^
;;;1 |  ---
;;;  | /   \
;;;---------------> x
;;;  0 1 2 3

;;; dx=0.1 일때
((smooth f) 0)   ; 0
((smooth f) 0.9) ; 1/3
((smooth f) 1)   ; 2/3
((smooth f) 1.1) ; 1
((smooth f) 2)   ; 1
((smooth f) 3)   ; 2/3


;;; n번 다듬는 함수
(define (n-fold-smooth n)
  (repeated smooth n))

(((n-fold-smooth 3) f ) 0)   ; 0
(((n-fold-smooth 3) f ) 0.9) ; 31/81
(((n-fold-smooth 3) f ) 1)   ; 50/81
(((n-fold-smooth 3) f ) 1.1) ; 22/27
(((n-fold-smooth 3) f ) 2)   ; 1
(((n-fold-smooth 3) f ) 3)   ; 50/81


;;;--------------------------< ex 1.45 >--------------------------
;;; p100

;; y^3 = x
;; => y |-> x / y^2
((lambda (x)
  (fixed-point (average-damp (lambda (y) (/ x (square y)))) 0.1))
 1)
; 0.9999979647655368

;; y^4 = x
;; => y |-> x / y^3
((lambda (x)
  (fixed-point (average-damp (lambda (y) (/ x (cube y)))) 0.1))
 1) ; 평균내어잠재우기 1번 -> 답 안나옴

((lambda (x)
  (fixed-point ((repeated average-damp 2) (lambda (y) (/ x (cube y)))) 0.1))
 1) ; 평균내어잠재우기 2번 
; 1.0000000000394822

;; y^5 = x
((lambda (x)
  (fixed-point ((repeated average-damp 2) (lambda (y) (/ x (* y y y y)))) 0.1))
 1) 
 ; 평균내어잠재우기 2번 -> 1.0000000000394822

;;;-----------------------------
;; n sqrt를 m번 평균잠재워서 구하는 함수를 만드는 함수
(define (gen-fp-nsqrt m-damp n-pow)
  (lambda (x)
    (fixed-point ((repeated average-damp m-damp) (lambda (y) 
						   (/ x (expt y (- n-pow 1)))))
		 0.1)))

;; y^3 = x
((gen-fp-nsqrt 1 3) 1) ; 0.9999979647655368

;; y^4 = x
((gen-fp-nsqrt 1 4) 1) ; x
((gen-fp-nsqrt 2 4) 1) ; 1.0000000000394822

;; y^5 = x
((gen-fp-nsqrt 1 5) 1) ; x
((gen-fp-nsqrt 2 5) 1) ; 1.0000005231525688

;; y^6 = x
((gen-fp-nsqrt 1 6) 1) ; x
((gen-fp-nsqrt 2 6) 1) ; 1.0000025135159185

;; y^7 = x
((gen-fp-nsqrt 1 7) 1) ; 0.9999982817926396
((gen-fp-nsqrt 2 7) 1) ; 0.9999964281410385

;; y^8 = x
((gen-fp-nsqrt 2 8) 1) ; x
((gen-fp-nsqrt 3 8) 1) ; 1.0000070713124947

;; y^9 = x
((gen-fp-nsqrt 2 9) 1) ; x
((gen-fp-nsqrt 3 9) 1) ; 1.0000039048439704

;; y^10 = x
((gen-fp-nsqrt 2 10) 1) ; x
((gen-fp-nsqrt 3 10) 1) ; 1.0000000000394822

;; y^11 = x
((gen-fp-nsqrt 2 11) 1) ; x
((gen-fp-nsqrt 3 11) 1) ; 1.000002632280844

;; y^12 = x
((gen-fp-nsqrt 2 12) 1) ; 1.0000006655983138
((gen-fp-nsqrt 3 12) 1) ; 1.0000008866907955

;; y^15 = x
((gen-fp-nsqrt 2 15) 1) ; 1.0000065559266993
((gen-fp-nsqrt 3 15) 1) ; 1.000000079561101

;; y^16 = x
((gen-fp-nsqrt 2 16) 1) ; 1.0000053925024897
((gen-fp-nsqrt 3 16) 1) ; 1.0000000000954519


;;;---
(define (cube x)
  (* x x x))

(define (square x)
  (* x x))

(define (average-damp f)
  (lambda (x) (average x (f x))))

(define (average x y)
  (/ (+ x y) 2))     
;;;---

;;;--------------------------< ex 1.46 >--------------------------
;;; p100

(define (iterative-improve1 f-improve f-good-enough? guess)
  (define (iter guess x)
    (if (f-good-enough? guess x)
	guess
	(iter (f-improve guess) x)))
  (lambda (x)
    (iter 1.0 x)))



;;; p40의 sqrt를 아래와 같이 고침
;; sqrt -> iterative-improve
(define (sqrt-new x)
  (define (improve guess)
    (average guess (/ x guess)))
  (define (good-enough? guess x)
    (< (abs (- (square guess) x)) 0.001))
  ((iterative-improve1 improve good-enough? 1.0) x))

(sqrt-new 9) ; 3.00009155413138

;-------------------------------------------------------------


(define (iterative-improve2 f-improve f-good-enough?)
  (define (iter guess)
    (let ((next (f-improve guess)))
      (if (f-good-enough? guess next)
	  next 
	  (iter next))))
  (lambda (first-guess)
    (iter first-guess)))


;;; p88의 fixed-point를 아래와 같이 고침
(define tolerance 0.00001)

(define (fixed-point-new f first-guess)
  (define (close-enough? v1 v2)
    (< (abs (- v1 v2)) tolerance))
  ((iterative-improve2 f close-enough?) first-guess))

(fixed-point-new cos 1.0)
(fixed-point-new (lambda (y) (+ (sin y) (cos y))) 1.0)

;;; p89의 sqrt를 다음과 같이 고침
;; sqrt -> fixed-point-new -> iterative-improve
(define (sqrt-new2 x)
  (fixed-point-new (lambda (y) (average y (/ x y)))
		   1.0))

(sqrt-new2 9)