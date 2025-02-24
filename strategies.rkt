#lang racket

;; You can require more modules of your choice.
(require racket/list
         (prefix-in utils: "utils.rkt")
         (prefix-in stats: "statistics.rkt"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                     ;;
;; Strategies                                                                          ;;
;; ==========                                                                          ;;
;; For the purpose of this assignment, just the `etai` strategy is expected, since     ;;
;; we have dictionary-closure and secret-word-enumeration to leap-frog to the right    ;;
;; key. This technique would fail for harder keys which are arbitrary permutations of  ;;
;; the alphabet. We will be forced to explore many more strategies (along with         ;;
;; dictionary-closure of course).                                                      ;;
;;                                                                                     ;;
;; Strategies to guess substitutions for the key using statistical information about   ;;
;; - the English language from utils.rkt                                               ;;
;; - the cipher text      from statistics.rkt                                          ;;
;;                                                                                     ;;
;; Follow the function signature as indicated below. Deviations will make it           ;;
;; impossible for automatic grading of your submission.                                ;;
;; Moreover, we do not expect your strategies to require any more/different            ;;
;; arguments. Note that you recieve the key as argument, so you can at the very        ;;
;; least ensure that all the substitutions are monoalphabetic wrt this key.            ;;
;;                                                                                     ;;
;; Signature:                                                                          ;;
;; ```                                                                                 ;;
;; (define (my-fundoo-strategy key)                                                    ;;
;;   ;; Make use of `utils:ciphertext`, `utils:cipher-word-list`                       ;;
;;   ...)                                                                              ;;
;; ```                                                                                 ;;
;;                                                                                     ;;
;; Substitutions                                                                       ;;
;; -------------                                                                       ;;
;; In order to extend the key incrementally, we use `utils:add-substitution` to        ;;
;; extend a given key with a substitution.                                             ;;
;;                                                                                     ;;
;; A substitution is a list of pairs, each pair mapping a plaintext char to a          ;;
;; ciphertext char. For example, to extend the key with T -> a and O -> r              ;;
;; (simultaneously), we use the substitution:                                          ;;
;; ```                                                                                 ;;
;; (list (cons #\T #\a) (cons #\O #\r))                                                ;;
;; ```                                                                                 ;;
;; For a single substitution use a singleton list (containing just one pair).          ;;
;;                                                                                     ;;
;; **CAUTION**                                                                         ;;
;; -----------                                                                         ;;
;; 1. Note that add-substitution does not do sanity checks on the substitution and use ;;
;;    of `utils:is-monoalphabetic` is recommended to ensure that you don't             ;;
;;    inadvertently create invalid keys.                                               ;;
;; 2. You must provide a list called `compositions` in this module.                    ;;
;;                                                                                     ;;
;; See docs in "utils.rkt" for more information.                                       ;;
;;                                                                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; You must add "public" functions of this module to this list.
(provide etai
         ;; Some more suggested strategies:
         
         ;; common-words-double
         ;; bigrams
         ;; common-initial-letters
         ;; common-final-letters
         ;; common-words-triple
         ;; trigrams
         ;; common-double-letters
         ;; common-words-quadruple
         ;; quadgrams
         
         ;; lists of strategies
         composition)

;; A strategy that uses some statistical information to generate potential
;; substitutions for E, T, A and I.
;; Refer the assignment manual for tips on developing this strategy. You can
;; interact with our etai with the executable we provide.
(define (etai key)
  (define (helper l1 l2 acc)
    (cond [(null? l2) acc]
          [else (helper l1 (cdr l2) (append acc (list (map cons l1 (car l2)))))]))
  (define (subtract l1 l2)
    (cond [(null? l2) l1]
          [else (subtract (remove (car l2) l1) (cdr l2))]))
  (define (join l l1 acc)
    (append* (map (lambda (x) (list (append x l1) (append x (reverse l1)))) l)))
  (define (choose2 l)
    (cond [(null? (cddr l)) (list l (reverse l))]
          [else (append (append* (map (lambda (x) (list (list (car l) x) (list x (car l)))) (cdr l))) (choose2 (cdr l)))]))
  (define singles1 (map (compose1 car string->list) (stats:cipher-common-words-single utils:cipher-word-list)))
  (define singles (cond [(= 1 (length singles1)) (append singles1 (list #\_))]
                        [(= 0 (length singles1)) (list #\_ #\_)]
                        [else singles1]))
  (define top5 (take (stats:cipher-monograms utils:ciphertext) 5))
  (define rem (subtract top5 singles))
  (define only-cipher (join (choose2 rem) singles '())) 
  (helper '(#\E #\T #\A #\I) (remove-duplicates only-cipher) '()))



;; A suggested composition of strategies that might work well. Has not been
;; exhaustively tested by us. Be original ;)
(define composition (list etai))
                  ;; common-words-double
                  ;; bigrams
                  ;; common-initial-letters
                  ;; common-final-letters
                  ;; common-words-triple
                  ;; trigrams
                  ;; common-double-letters))
                  ;; common-words-quadruple
                  ;; quadgrams))

