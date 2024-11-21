;; LearnQ - Educational Platform Smart Contract
;; This contract manages the learning platform's core functionality
;; including course completion tracking and token rewards

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-insufficient-balance (err u103))

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

;; Public Functions
(define-public (create-course (course-id uint) (title (string-utf8 100)) (reward uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-none (get-course course-id)) err-already-exists)
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
    )
        (asserts! (get completed progress) err-not-found)
        (asserts! (not (get reward-claimed progress)) err-already-exists)
        
        (map-set user-progress progress-key 
            (merge progress {reward-claimed: true}))
        (mint-tokens tx-sender (get reward course))
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