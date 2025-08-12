;; Local Deals Platform Contract
;; Author: Vedant
;; Language: Clarity

;; -----------------------------
;; Data Structures
;; -----------------------------

(define-map deals uint
  {
    seller: principal,
    title: (string-ascii 50),
    price: uint,
    quantity: uint
  }
)

(define-data-var deal-counter uint u0)

(define-constant err-invalid-amount (err u100))
(define-constant err-out-of-stock (err u101))
(define-constant err-not-found (err u102))

;; -----------------------------
;; Function 1: Post a deal
;; -----------------------------
(define-public (post-deal (title (string-ascii 50)) (price uint) (quantity uint))
  (begin
    (asserts! (> price u0) err-invalid-amount)
    (asserts! (> quantity u0) err-invalid-amount)

    (var-set deal-counter (+ (var-get deal-counter) u1))
    (map-set deals (var-get deal-counter)
      {
        seller: tx-sender,
        title: title,
        price: price,
        quantity: quantity
      }
    )
    (ok (var-get deal-counter))
  )
)

;; -----------------------------
;; Function 2: Purchase a deal
;; -----------------------------
(define-public (purchase-deal (deal-id uint))
  (let
    (
      (deal-data (map-get? deals deal-id))
    )
    (match deal-data deal
      (begin
        (asserts! (> (get quantity deal) u0) err-out-of-stock)
        (try! (stx-transfer? (get price deal) tx-sender (get seller deal)))
        (map-set deals deal-id
          {
            seller: (get seller deal),
            title: (get title deal),
            price: (get price deal),
            quantity: (- (get quantity deal) u1)
          }
        )
        (ok true)
      )
      (err u102) ;; fixed error return
    )
  )
)
