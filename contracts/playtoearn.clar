;; LearnQ - Educational Platform Smart Contract
;; This contract manages the learning platform's core functionality
;; including course completion tracking and token rewards

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-insufficient-balance (err u103))
(define-constant err-invalid-input (err u104))
(define-constant max-reward-amount u1000000) ;; Maximum tokens that can be rewarded
(define-constant min-reward-amount u1) ;; Minimum tokens that can be rewarded
(define-constant empty-title u"")

;; Data Variables
(define-data-var token-name (string-ascii 32) "LEARN")
(define-data-var token-symbol (string-ascii 10) "LRN")
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var total-supply uint u0)

;; Data Maps
(define-map balances principal uint)
(define-map courses uint {
    title: (string-utf8 100),
    reward: uint,
    active: bool
})
(define-map user-progress (tuple (user principal) (course-id uint)) {
    completed: bool,
    reward-claimed: bool
})

;; Private Functions for Input Validation
(define-private (validate-title (title (string-utf8 100)))
    (let
        ((title-length (len title)))
        (and
            (>= title-length u1)  ;; Title must not be empty
            (<= title-length u100) ;; Title must not exceed max length
            (not (is-eq title empty-title))  ;; Compare with UTF-8 empty string constant
        )
    )
)

(define-private (validate-reward (reward uint))
    (and
        (>= reward min-reward-amount)
        (<= reward max-reward-amount)
    )
)

(define-private (validate-course-id (course-id uint))
    (and
        (> course-id u0)
        (is-none (get-course course-id))
    )
)

;; Public Functions
(define-public (create-course (course-id uint) (title (string-utf8 100)) (reward uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (validate-course-id course-id) err-already-exists)
        (asserts! (validate-title title) err-invalid-input)
        (asserts! (validate-reward reward) err-invalid-input)
        
        (ok (map-set courses course-id {
            title: title,
            reward: reward,
            active: true
        }))
    )
)

(define-public (complete-course (course-id uint))
    (let (
        (course (unwrap! (get-course course-id) err-not-found))
        (progress-key {user: tx-sender, course-id: course-id})
    )
        (asserts! (get active course) err-not-found)
        (asserts! (> course-id u0) err-invalid-input)
        (asserts! (not (get completed (default-to 
            {completed: false, reward-claimed: false} 
            (map-get? user-progress progress-key)
        ))) err-already-exists)
        
        (map-set user-progress progress-key {
            completed: true,
            reward-claimed: false
        })
        (ok true)
    )
)

(define-public (claim-reward (course-id uint))
    (let (
        (course (unwrap! (get-course course-id) err-not-found))
        (progress-key {user: tx-sender, course-id: course-id})
        (progress (unwrap! (map-get? user-progress progress-key) err-not-found))
        (reward-amount (get reward course))
    )
        (asserts! (> course-id u0) err-invalid-input)
        (asserts! (get completed progress) err-not-found)
        (asserts! (not (get reward-claimed progress)) err-already-exists)
        (asserts! (validate-reward reward-amount) err-invalid-input)
        
        ;; Update progress first
        (map-set user-progress progress-key 
            (merge progress {reward-claimed: true}))
        
        ;; Then mint tokens
        (mint-tokens tx-sender reward-amount)
    )
)

;; Read-Only Functions
(define-read-only (get-course (course-id uint))
    (map-get? courses course-id)
)

(define-read-only (get-user-progress (user principal) (course-id uint))
    (map-get? user-progress {user: user, course-id: course-id})
)

(define-read-only (get-balance (account principal))
    (default-to u0 (map-get? balances account))
)

;; Private Functions
(define-private (mint-tokens (recipient principal) (amount uint))
    (begin
        (try! (is-owner))
        (asserts! (validate-reward amount) err-invalid-input)
        (asserts! (<= (+ (var-get total-supply) amount) 
                     (pow u10 u18)) err-insufficient-balance)
        
        (map-set balances 
            recipient 
            (+ (get-balance recipient) amount))
        (var-set total-supply 
            (+ (var-get total-supply) amount))
        (ok true)
    )
)

(define-private (is-owner)
    (if (is-eq tx-sender contract-owner)
        (ok true)
        err-owner-only
    )
)