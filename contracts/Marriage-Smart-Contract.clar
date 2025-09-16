(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-married (err u102))
(define-constant err-not-married (err u103))
(define-constant err-unauthorized (err u104))
(define-constant err-proposal-not-found (err u105))
(define-constant err-already-proposed (err u106))
(define-constant err-same-person (err u107))
(define-constant err-insufficient-funds (err u108))
(define-constant err-invalid-amount (err u109))
(define-constant err-marriage-fee-required (err u110))
(define-constant err-registry-not-found (err u111))
(define-constant err-registry-exists (err u112))
(define-constant err-registry-inactive (err u113))
(define-constant err-item-not-found (err u114))
(define-constant err-item-fulfilled (err u115))
(define-constant err-invalid-contributor (err u116))
(define-constant err-mentorship-not-found (err u117))
(define-constant err-mentorship-exists (err u118))
(define-constant err-invalid-mentor (err u119))
(define-constant err-mentorship-completed (err u120))
(define-constant err-session-not-found (err u121))

(define-data-var marriage-fee uint u1000000)
(define-data-var total-marriages uint u0)
(define-data-var contract-balance uint u0)

(define-map proposals
    {
        proposer: principal,
        proposee: principal,
    }
    {
        proposal-id: uint,
        message: (string-ascii 500),
        ring-value: uint,
        proposal-block: uint,
        accepted: bool,
    }
)

(define-map marriages
    {
        partner-1: principal,
        partner-2: principal,
    }
    {
        marriage-id: uint,
        marriage-block: uint,
        prenup-terms: (string-ascii 1000),
        shared-assets: uint,
        anniversary-block: uint,
        status: (string-ascii 20),
    }
)

(define-map divorce-requests
    {
        requester: principal,
        spouse: principal,
    }
    {
        request-block: uint,
        reason: (string-ascii 500),
        asset-split: uint,
        approved: bool,
    }
)

(define-map user-profiles
    { user: principal }
    {
        display-name: (string-ascii 50),
        relationship-status: (string-ascii 20),
        partner: (optional principal),
        marriage-count: uint,
        created-block: uint,
    }
)

(define-map marriage-certificates
    { certificate-id: uint }
    {
        partner-1: principal,
        partner-2: principal,
        issued-block: uint,
        witness-1: (optional principal),
        witness-2: (optional principal),
        location: (string-ascii 100),
        certificate-hash: (buff 32),
    }
)

(define-map gift-registries
    { registry-id: uint }
    {
        partner-1: principal,
        partner-2: principal,
        title: (string-ascii 100),
        description: (string-ascii 500),
        target-amount: uint,
        collected-amount: uint,
        created-block: uint,
        status: (string-ascii 20),
    }
)

(define-map gift-items
    { item-id: uint }
    {
        registry-id: uint,
        item-name: (string-ascii 100),
        item-description: (string-ascii 300),
        item-price: uint,
        fulfilled: bool,
        fulfilled-by: (optional principal),
    }
)

(define-map gift-contributions
    {
        registry-id: uint,
        contributor: principal,
    }
    {
        amount: uint,
        contribution-block: uint,
        message: (string-ascii 200),
    }
)

(define-map mentorship-programs
    { mentorship-id: uint }
    {
        mentor-partner-1: principal,
        mentor-partner-2: principal,
        mentee-partner-1: principal,
        mentee-partner-2: principal,
        program-start-block: uint,
        program-end-block: uint,
        sessions-completed: uint,
        total-sessions: uint,
        mentor-fee: uint,
        status: (string-ascii 20),
        program-focus: (string-ascii 200),
    }
)

(define-map mentorship-sessions
    {
        mentorship-id: uint,
        session-number: uint,
    }
    {
        session-date: uint,
        session-notes: (string-ascii 500),
        mentor-rating: uint,
        mentee-rating: uint,
        session-completed: bool,
    }
)

(define-map mentor-profiles
    { mentor-couple-id: uint }
    {
        partner-1: principal,
        partner-2: principal,
        marriage-years: uint,
        specializations: (string-ascii 300),
        total-mentorships: uint,
        average-rating: uint,
        mentor-fee-rate: uint,
        available: bool,
    }
)

(define-data-var next-proposal-id uint u1)
(define-data-var next-marriage-id uint u1)
(define-data-var next-certificate-id uint u1)
(define-data-var next-registry-id uint u1)
(define-data-var next-gift-item-id uint u1)
(define-data-var next-mentorship-id uint u1)
(define-data-var next-mentor-couple-id uint u1)

(define-read-only (get-marriage-fee)
    (var-get marriage-fee)
)

(define-read-only (get-total-marriages)
    (var-get total-marriages)
)

(define-read-only (get-contract-balance)
    (var-get contract-balance)
)

(define-read-only (get-proposal
        (proposer principal)
        (proposee principal)
    )
    (map-get? proposals {
        proposer: proposer,
        proposee: proposee,
    })
)

(define-read-only (get-marriage
        (partner-1 principal)
        (partner-2 principal)
    )
    (match (map-get? marriages {
        partner-1: partner-1,
        partner-2: partner-2,
    })
        marriage (some marriage)
        (map-get? marriages {
            partner-1: partner-2,
            partner-2: partner-1,
        })
    )
)

(define-read-only (get-user-profile (user principal))
    (map-get? user-profiles { user: user })
)

(define-read-only (get-divorce-request
        (requester principal)
        (spouse principal)
    )
    (map-get? divorce-requests {
        requester: requester,
        spouse: spouse,
    })
)

(define-read-only (get-marriage-certificate (certificate-id uint))
    (map-get? marriage-certificates { certificate-id: certificate-id })
)

(define-read-only (is-married (user principal))
    (match (get-user-profile user)
        profile (is-eq (get relationship-status profile) "married")
        false
    )
)

(define-read-only (get-partner (user principal))
    (match (get-user-profile user)
        profile (get partner profile)
        none
    )
)

(define-public (create-profile (display-name (string-ascii 50)))
    (let ((user-data {
            display-name: display-name,
            relationship-status: "single",
            partner: none,
            marriage-count: u0,
            created-block: stacks-block-height,
        }))
        (map-set user-profiles { user: tx-sender } user-data)
        (ok true)
    )
)

(define-public (propose-marriage
        (proposee principal)
        (message (string-ascii 500))
        (ring-value uint)
    )
    (let (
            (proposal-id (var-get next-proposal-id))
            (existing-proposal (get-proposal tx-sender proposee))
        )
        (asserts! (not (is-eq tx-sender proposee)) err-same-person)
        (asserts! (not (is-married tx-sender)) err-already-married)
        (asserts! (not (is-married proposee)) err-already-married)
        (asserts! (is-none existing-proposal) err-already-proposed)
        (asserts! (>= ring-value u100000) err-invalid-amount)

        (try! (stx-transfer? ring-value tx-sender (as-contract tx-sender)))

        (map-set proposals {
            proposer: tx-sender,
            proposee: proposee,
        } {
            proposal-id: proposal-id,
            message: message,
            ring-value: ring-value,
            proposal-block: stacks-block-height,
            accepted: false,
        })

        (var-set next-proposal-id (+ proposal-id u1))
        (ok proposal-id)
    )
)

(define-public (accept-proposal (proposer principal))
    (let (
            (proposal (unwrap! (get-proposal proposer tx-sender) err-proposal-not-found))
            (marriage-id (var-get next-marriage-id))
        )
        (asserts! (not (is-married tx-sender)) err-already-married)
        (asserts! (not (is-married proposer)) err-already-married)
        (asserts! (not (get accepted proposal)) err-proposal-not-found)

        (map-set proposals {
            proposer: proposer,
            proposee: tx-sender,
        }
            (merge proposal { accepted: true })
        )

        (unwrap! (execute-marriage proposer tx-sender "" u0) err-not-found)
        (ok marriage-id)
    )
)

(define-public (reject-proposal (proposer principal))
    (let ((proposal (unwrap! (get-proposal proposer tx-sender) err-proposal-not-found)))
        (try! (as-contract (stx-transfer? (get ring-value proposal) tx-sender proposer)))
        (map-delete proposals {
            proposer: proposer,
            proposee: tx-sender,
        })
        (ok true)
    )
)

(define-public (marry-with-prenup
        (partner principal)
        (prenup-terms (string-ascii 1000))
        (shared-assets uint)
    )
    (begin
        (asserts! (not (is-eq tx-sender partner)) err-same-person)
        (asserts! (not (is-married tx-sender)) err-already-married)
        (asserts! (not (is-married partner)) err-already-married)
        (try! (stx-transfer? (var-get marriage-fee) tx-sender (as-contract tx-sender)))
        (unwrap! (execute-marriage tx-sender partner prenup-terms shared-assets)
            err-not-found
        )
        (ok (var-get next-marriage-id))
    )
)

(define-private (execute-marriage
        (partner-1 principal)
        (partner-2 principal)
        (prenup (string-ascii 1000))
        (assets uint)
    )
    (let (
            (marriage-id (var-get next-marriage-id))
            (current-block stacks-block-height)
            (certificate-id (var-get next-certificate-id))
        )
        (map-set marriages {
            partner-1: partner-1,
            partner-2: partner-2,
        } {
            marriage-id: marriage-id,
            marriage-block: current-block,
            prenup-terms: prenup,
            shared-assets: assets,
            anniversary-block: (+ current-block u52560),
            status: "active",
        })

        (map-set user-profiles { user: partner-1 } {
            display-name: (default-to "Unknown" (get display-name (get-user-profile partner-1))),
            relationship-status: "married",
            partner: (some partner-2),
            marriage-count: (+ (default-to u0 (get marriage-count (get-user-profile partner-1)))
                u1
            ),
            created-block: (default-to current-block
                (get created-block (get-user-profile partner-1))
            ),
        })

        (map-set user-profiles { user: partner-2 } {
            display-name: (default-to "Unknown" (get display-name (get-user-profile partner-2))),
            relationship-status: "married",
            partner: (some partner-1),
            marriage-count: (+ (default-to u0 (get marriage-count (get-user-profile partner-2)))
                u1
            ),
            created-block: (default-to current-block
                (get created-block (get-user-profile partner-2))
            ),
        })

        (map-set marriage-certificates { certificate-id: certificate-id } {
            partner-1: partner-1,
            partner-2: partner-2,
            issued-block: current-block,
            witness-1: none,
            witness-2: none,
            location: "Stacks Blockchain",
            certificate-hash: (keccak256 (concat (unwrap-panic (to-consensus-buff? partner-1))
                (unwrap-panic (to-consensus-buff? partner-2))
            )),
        })

        (var-set next-marriage-id (+ marriage-id u1))
        (var-set next-certificate-id (+ certificate-id u1))
        (var-set total-marriages (+ (var-get total-marriages) u1))
        (var-set contract-balance
            (+ (var-get contract-balance) (var-get marriage-fee))
        )
        (ok marriage-id)
    )
)

(define-public (request-divorce
        (spouse principal)
        (reason (string-ascii 500))
        (asset-split uint)
    )
    (let ((marriage (unwrap! (get-marriage tx-sender spouse) err-not-married)))
        (asserts! (is-eq (get status marriage) "active") err-not-married)
        (asserts! (<= asset-split u100) err-invalid-amount)

        (map-set divorce-requests {
            requester: tx-sender,
            spouse: spouse,
        } {
            request-block: stacks-block-height,
            reason: reason,
            asset-split: asset-split,
            approved: false,
        })
        (ok true)
    )
)

(define-public (approve-divorce (requester principal))
    (let (
            (divorce-req (unwrap! (get-divorce-request requester tx-sender) err-not-found))
            (marriage (unwrap! (get-marriage requester tx-sender) err-not-married))
            (shared-assets (get shared-assets marriage))
            (split-percentage (get asset-split divorce-req))
        )
        (asserts! (is-eq (get status marriage) "active") err-not-married)

        (map-set divorce-requests {
            requester: requester,
            spouse: tx-sender,
        }
            (merge divorce-req { approved: true })
        )

        (unwrap!
            (execute-divorce requester tx-sender shared-assets split-percentage)
            err-not-found
        )
        (ok true)
    )
)

(define-private (execute-divorce
        (partner-1 principal)
        (partner-2 principal)
        (assets uint)
        (split uint)
    )
    (let (
            (partner-1-share (/ (* assets split) u100))
            (partner-2-share (- assets partner-1-share))
        )
        (map-set marriages {
            partner-1: partner-1,
            partner-2: partner-2,
        } {
            marriage-id: (default-to u0 (get marriage-id (get-marriage partner-1 partner-2))),
            marriage-block: (default-to u0
                (get marriage-block (get-marriage partner-1 partner-2))
            ),
            prenup-terms: (default-to "" (get prenup-terms (get-marriage partner-1 partner-2))),
            shared-assets: u0,
            anniversary-block: u0,
            status: "divorced",
        })

        (map-set user-profiles { user: partner-1 } {
            display-name: (default-to "Unknown" (get display-name (get-user-profile partner-1))),
            relationship-status: "divorced",
            partner: none,
            marriage-count: (default-to u0 (get marriage-count (get-user-profile partner-1))),
            created-block: (default-to stacks-block-height
                (get created-block (get-user-profile partner-1))
            ),
        })

        (map-set user-profiles { user: partner-2 } {
            display-name: (default-to "Unknown" (get display-name (get-user-profile partner-2))),
            relationship-status: "divorced",
            partner: none,
            marriage-count: (default-to u0 (get marriage-count (get-user-profile partner-2))),
            created-block: (default-to stacks-block-height
                (get created-block (get-user-profile partner-2))
            ),
        })

        (if (> partner-1-share u0)
            (try! (as-contract (stx-transfer? partner-1-share tx-sender partner-1)))
            true
        )

        (if (> partner-2-share u0)
            (try! (as-contract (stx-transfer? partner-2-share tx-sender partner-2)))
            true
        )

        (map-delete divorce-requests {
            requester: partner-1,
            spouse: partner-2,
        })
        (map-delete divorce-requests {
            requester: partner-2,
            spouse: partner-1,
        })
        (ok true)
    )
)

(define-public (add-shared-assets (amount uint))
    (let (
            (partner (unwrap! (get-partner tx-sender) err-not-married))
            (marriage (unwrap! (get-marriage tx-sender partner) err-not-married))
        )
        (asserts! (is-eq (get status marriage) "active") err-not-married)
        (asserts! (> amount u0) err-invalid-amount)

        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

        (map-set marriages {
            partner-1: tx-sender,
            partner-2: partner,
        }
            (merge marriage { shared-assets: (+ (get shared-assets marriage) amount) })
        )

        (var-set contract-balance (+ (var-get contract-balance) amount))
        (ok true)
    )
)

(define-public (withdraw-shared-assets (amount uint))
    (let (
            (partner (unwrap! (get-partner tx-sender) err-not-married))
            (marriage (unwrap! (get-marriage tx-sender partner) err-not-married))
            (current-assets (get shared-assets marriage))
        )
        (asserts! (is-eq (get status marriage) "active") err-not-married)
        (asserts! (<= amount current-assets) err-insufficient-funds)
        (asserts! (> amount u0) err-invalid-amount)

        (try! (as-contract (stx-transfer? (/ amount u2) tx-sender tx-sender)))
        (try! (as-contract (stx-transfer? (/ amount u2) tx-sender partner)))

        (map-set marriages {
            partner-1: tx-sender,
            partner-2: partner,
        }
            (merge marriage { shared-assets: (- current-assets amount) })
        )

        (var-set contract-balance (- (var-get contract-balance) amount))
        (ok true)
    )
)

(define-public (add-witness-to-certificate
        (certificate-id uint)
        (witness principal)
    )
    (let ((cert (unwrap! (get-marriage-certificate certificate-id) err-not-found)))
        (asserts!
            (or (is-eq tx-sender (get partner-1 cert)) (is-eq tx-sender (get partner-2 cert)))
            err-unauthorized
        )

        (map-set marriage-certificates { certificate-id: certificate-id }
            (if (is-none (get witness-1 cert))
                (merge cert { witness-1: (some witness) })
                (merge cert { witness-2: (some witness) })
            ))
        (ok true)
    )
)

(define-public (renew-vows (new-prenup (string-ascii 1000)))
    (let (
            (partner (unwrap! (get-partner tx-sender) err-not-married))
            (marriage (unwrap! (get-marriage tx-sender partner) err-not-married))
        )
        (asserts! (is-eq (get status marriage) "active") err-not-married)

        (map-set marriages {
            partner-1: tx-sender,
            partner-2: partner,
        }
            (merge marriage {
                prenup-terms: new-prenup,
                anniversary-block: (+ stacks-block-height u52560),
            })
        )
        (ok true)
    )
)

(define-public (celebrate-anniversary)
    (let (
            (partner (unwrap! (get-partner tx-sender) err-not-married))
            (marriage (unwrap! (get-marriage tx-sender partner) err-not-married))
        )
        (asserts! (is-eq (get status marriage) "active") err-not-married)
        (asserts! (>= stacks-block-height (get anniversary-block marriage))
            err-unauthorized
        )

        (try! (as-contract (stx-transfer? u500000 tx-sender tx-sender)))
        (try! (as-contract (stx-transfer? u500000 tx-sender partner)))

        (map-set marriages {
            partner-1: tx-sender,
            partner-2: partner,
        }
            (merge marriage { anniversary-block: (+ stacks-block-height u52560) })
        )

        (ok true)
    )
)

(define-public (update-marriage-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> new-fee u0) err-invalid-amount)
        (var-set marriage-fee new-fee)
        (ok true)
    )
)

(define-public (emergency-pause-marriage
        (partner-1 principal)
        (partner-2 principal)
    )
    (let ((marriage (unwrap! (get-marriage partner-1 partner-2) err-not-married)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)

        (map-set marriages {
            partner-1: partner-1,
            partner-2: partner-2,
        }
            (merge marriage { status: "paused" })
        )
        (ok true)
    )
)

(define-public (resume-marriage
        (partner-1 principal)
        (partner-2 principal)
    )
    (let ((marriage (unwrap! (get-marriage partner-1 partner-2) err-not-married)))
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (is-eq (get status marriage) "paused") err-not-found)

        (map-set marriages {
            partner-1: partner-1,
            partner-2: partner-2,
        }
            (merge marriage { status: "active" })
        )
        (ok true)
    )
)

(define-public (withdraw-contract-fees (amount uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (<= amount (var-get contract-balance)) err-insufficient-funds)

        (try! (as-contract (stx-transfer? amount tx-sender contract-owner)))
        (var-set contract-balance (- (var-get contract-balance) amount))
        (ok true)
    )
)

(define-read-only (get-marriage-stats)
    {
        total-marriages: (var-get total-marriages),
        current-fee: (var-get marriage-fee),
        contract-balance: (var-get contract-balance),
        next-proposal-id: (var-get next-proposal-id),
        next-marriage-id: (var-get next-marriage-id),
    }
)

(define-read-only (calculate-anniversary-reward (marriage-years uint))
    (if (<= marriage-years u1)
        u100000
        (if (<= marriage-years u5)
            u500000
            (if (<= marriage-years u10)
                u1000000
                u2000000
            )
        )
    )
)

(define-read-only (get-marriage-duration
        (partner-1 principal)
        (partner-2 principal)
    )
    (match (get-marriage partner-1 partner-2)
        marriage (- stacks-block-height (get marriage-block marriage))
        u0
    )
)

(define-read-only (is-anniversary-due
        (partner-1 principal)
        (partner-2 principal)
    )
    (match (get-marriage partner-1 partner-2)
        marriage (>= stacks-block-height (get anniversary-block marriage))
        false
    )
)

(define-public (create-gift-registry
        (title (string-ascii 100))
        (description (string-ascii 500))
        (target-amount uint)
    )
    (let (
            (partner (unwrap! (get-partner tx-sender) err-not-married))
            (marriage (unwrap! (get-marriage tx-sender partner) err-not-married))
            (registry-id (var-get next-registry-id))
        )
        (asserts! (is-eq (get status marriage) "active") err-not-married)
        (asserts! (> target-amount u0) err-invalid-amount)

        (map-set gift-registries { registry-id: registry-id } {
            partner-1: tx-sender,
            partner-2: partner,
            title: title,
            description: description,
            target-amount: target-amount,
            collected-amount: u0,
            created-block: stacks-block-height,
            status: "active",
        })

        (var-set next-registry-id (+ registry-id u1))
        (ok registry-id)
    )
)

(define-public (close-gift-registry (registry-id uint))
    (let ((registry (unwrap! (get-gift-registry registry-id) err-registry-not-found)))
        (asserts!
            (or
                (is-eq tx-sender (get partner-1 registry))
                (is-eq tx-sender (get partner-2 registry))
            )
            err-unauthorized
        )
        (asserts! (is-eq (get status registry) "active") err-registry-inactive)

        (map-set gift-registries { registry-id: registry-id }
            (merge registry { status: "closed" })
        )
        (ok true)
    )
)

(define-public (add-gift-item
        (registry-id uint)
        (item-name (string-ascii 100))
        (item-description (string-ascii 300))
        (item-price uint)
    )
    (let (
            (registry (unwrap! (get-gift-registry registry-id) err-registry-not-found))
            (item-id (var-get next-gift-item-id))
        )
        (asserts!
            (or
                (is-eq tx-sender (get partner-1 registry))
                (is-eq tx-sender (get partner-2 registry))
            )
            err-unauthorized
        )
        (asserts! (is-eq (get status registry) "active") err-registry-inactive)
        (asserts! (> item-price u0) err-invalid-amount)

        (map-set gift-items { item-id: item-id } {
            registry-id: registry-id,
            item-name: item-name,
            item-description: item-description,
            item-price: item-price,
            fulfilled: false,
            fulfilled-by: none,
        })

        (var-set next-gift-item-id (+ item-id u1))
        (ok item-id)
    )
)

(define-public (fulfill-gift-item (item-id uint))
    (let ((item (unwrap! (get-gift-item item-id) err-item-not-found)))
        (asserts! (not (get fulfilled item)) err-item-fulfilled)

        (try! (stx-transfer? (get item-price item) tx-sender (as-contract tx-sender)))

        (map-set gift-items { item-id: item-id }
            (merge item {
                fulfilled: true,
                fulfilled-by: (some tx-sender),
            })
        )

        (let ((registry (unwrap! (get-gift-registry (get registry-id item))
                err-registry-not-found
            )))
            (map-set gift-registries { registry-id: (get registry-id item) }
                (merge registry { collected-amount: (+ (get collected-amount registry) (get item-price item)) })
            )
        )

        (ok true)
    )
)

(define-public (contribute-to-registry
        (registry-id uint)
        (amount uint)
        (message (string-ascii 200))
    )
    (let ((registry (unwrap! (get-gift-registry registry-id) err-registry-not-found)))
        (asserts! (is-eq (get status registry) "active") err-registry-inactive)
        (asserts! (> amount u0) err-invalid-amount)
        (asserts!
            (and
                (not (is-eq tx-sender (get partner-1 registry)))
                (not (is-eq tx-sender (get partner-2 registry)))
            )
            err-invalid-contributor
        )

        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

        (let ((existing-contribution (get-gift-contribution registry-id tx-sender)))
            (match existing-contribution
                contribution (map-set gift-contributions {
                    registry-id: registry-id,
                    contributor: tx-sender,
                }
                    (merge contribution {
                        amount: (+ (get amount contribution) amount),
                        message: message,
                    })
                )
                (map-set gift-contributions {
                    registry-id: registry-id,
                    contributor: tx-sender,
                } {
                    amount: amount,
                    contribution-block: stacks-block-height,
                    message: message,
                })
            )
        )

        (map-set gift-registries { registry-id: registry-id }
            (merge registry { collected-amount: (+ (get collected-amount registry) amount) })
        )

        (ok true)
    )
)

(define-public (withdraw-registry-funds (registry-id uint))
    (let ((registry (unwrap! (get-gift-registry registry-id) err-registry-not-found)))
        (asserts!
            (or
                (is-eq tx-sender (get partner-1 registry))
                (is-eq tx-sender (get partner-2 registry))
            )
            err-unauthorized
        )
        (asserts! (is-eq (get status registry) "closed") err-registry-inactive)

        (let (
                (withdrawal-amount (/ (get collected-amount registry) u2))
                (partner-1 (get partner-1 registry))
                (partner-2 (get partner-2 registry))
            )
            (try! (as-contract (stx-transfer? withdrawal-amount tx-sender partner-1)))
            (try! (as-contract (stx-transfer? withdrawal-amount tx-sender partner-2)))

            (map-set gift-registries { registry-id: registry-id }
                (merge registry { collected-amount: u0 })
            )
        )

        (ok true)
    )
)

(define-read-only (get-gift-registry (registry-id uint))
    (map-get? gift-registries { registry-id: registry-id })
)

(define-read-only (get-gift-item (item-id uint))
    (map-get? gift-items { item-id: item-id })
)

(define-read-only (get-gift-contribution
        (registry-id uint)
        (contributor principal)
    )
    (map-get? gift-contributions {
        registry-id: registry-id,
        contributor: contributor,
    })
)

(define-read-only (get-registry-progress (registry-id uint))
    (match (get-gift-registry registry-id)
        registry
        {
            target-amount: (get target-amount registry),
            collected-amount: (get collected-amount registry),
            completion-percentage: (/ (* (get collected-amount registry) u100)
                (get target-amount registry)
            ),
            status: (get status registry),
        }
        {
            target-amount: u0,
            collected-amount: u0,
            completion-percentage: u0,
            status: "not-found",
        }
    )
)

(define-read-only (get-next-registry-id)
    (var-get next-registry-id)
)

(define-read-only (get-next-gift-item-id)
    (var-get next-gift-item-id)
)

(define-read-only (get-mentorship-program (mentorship-id uint))
    (map-get? mentorship-programs { mentorship-id: mentorship-id })
)

(define-read-only (get-mentorship-session
        (mentorship-id uint)
        (session-number uint)
    )
    (map-get? mentorship-sessions {
        mentorship-id: mentorship-id,
        session-number: session-number,
    })
)

(define-read-only (get-mentor-profile (mentor-couple-id uint))
    (map-get? mentor-profiles { mentor-couple-id: mentor-couple-id })
)

(define-read-only (calculate-mentorship-reward (sessions-completed uint))
    (* sessions-completed u250000)
)

(define-public (register-as-mentor
        (specializations (string-ascii 300))
        (fee-rate uint)
    )
    (let (
            (partner (unwrap! (get-partner tx-sender) err-not-married))
            (marriage (unwrap! (get-marriage tx-sender partner) err-not-married))
            (mentor-couple-id (var-get next-mentor-couple-id))
            (marriage-duration (get-marriage-duration tx-sender partner))
        )
        (asserts! (is-eq (get status marriage) "active") err-not-married)
        (asserts! (>= marriage-duration u26280) err-invalid-amount)
        (asserts! (> fee-rate u0) err-invalid-amount)

        (map-set mentor-profiles { mentor-couple-id: mentor-couple-id } {
            partner-1: tx-sender,
            partner-2: partner,
            marriage-years: (/ marriage-duration u52560),
            specializations: specializations,
            total-mentorships: u0,
            average-rating: u0,
            mentor-fee-rate: fee-rate,
            available: true,
        })

        (var-set next-mentor-couple-id (+ mentor-couple-id u1))
        (ok mentor-couple-id)
    )
)

(define-public (start-mentorship-program
        (mentor-couple-id uint)
        (program-focus (string-ascii 200))
        (total-sessions uint)
        (program-duration uint)
    )
    (let (
            (mentor-profile (unwrap! (get-mentor-profile mentor-couple-id) err-invalid-mentor))
            (mentee-partner (unwrap! (get-partner tx-sender) err-not-married))
            (mentee-marriage (unwrap! (get-marriage tx-sender mentee-partner) err-not-married))
            (mentorship-id (var-get next-mentorship-id))
            (total-fee (* (get mentor-fee-rate mentor-profile) total-sessions))
        )
        (asserts! (is-eq (get status mentee-marriage) "active") err-not-married)
        (asserts! (get available mentor-profile) err-invalid-mentor)
        (asserts! (> total-sessions u0) err-invalid-amount)
        (asserts! (> program-duration u0) err-invalid-amount)
        (asserts!
            (not (or
                (is-eq tx-sender (get partner-1 mentor-profile))
                (is-eq tx-sender (get partner-2 mentor-profile))
            ))
            err-invalid-mentor
        )

        (try! (stx-transfer? total-fee tx-sender (as-contract tx-sender)))

        (map-set mentorship-programs { mentorship-id: mentorship-id } {
            mentor-partner-1: (get partner-1 mentor-profile),
            mentor-partner-2: (get partner-2 mentor-profile),
            mentee-partner-1: tx-sender,
            mentee-partner-2: mentee-partner,
            program-start-block: stacks-block-height,
            program-end-block: (+ stacks-block-height program-duration),
            sessions-completed: u0,
            total-sessions: total-sessions,
            mentor-fee: total-fee,
            status: "active",
            program-focus: program-focus,
        })

        (map-set mentor-profiles { mentor-couple-id: mentor-couple-id }
            (merge mentor-profile { available: false })
        )

        (var-set next-mentorship-id (+ mentorship-id u1))
        (ok mentorship-id)
    )
)

(define-public (complete-mentorship-session
        (mentorship-id uint)
        (session-notes (string-ascii 500))
        (mentor-rating uint)
        (mentee-rating uint)
    )
    (let (
            (program (unwrap! (get-mentorship-program mentorship-id)
                err-mentorship-not-found
            ))
            (current-session (+ (get sessions-completed program) u1))
        )
        (asserts!
            (or
                (is-eq tx-sender (get mentor-partner-1 program))
                (is-eq tx-sender (get mentor-partner-2 program))
                (is-eq tx-sender (get mentee-partner-1 program))
                (is-eq tx-sender (get mentee-partner-2 program))
            )
            err-unauthorized
        )
        (asserts! (is-eq (get status program) "active") err-mentorship-completed)
        (asserts! (<= current-session (get total-sessions program))
            err-invalid-amount
        )
        (asserts! (and (>= mentor-rating u1) (<= mentor-rating u5))
            err-invalid-amount
        )
        (asserts! (and (>= mentee-rating u1) (<= mentee-rating u5))
            err-invalid-amount
        )

        (map-set mentorship-sessions {
            mentorship-id: mentorship-id,
            session-number: current-session,
        } {
            session-date: stacks-block-height,
            session-notes: session-notes,
            mentor-rating: mentor-rating,
            mentee-rating: mentee-rating,
            session-completed: true,
        })

        (map-set mentorship-programs { mentorship-id: mentorship-id }
            (merge program { sessions-completed: current-session })
        )

        (if (is-eq current-session (get total-sessions program))
            (unwrap! (finalize-mentorship-program mentorship-id) err-not-found)
            true
        )

        (ok true)
    )
)

(define-private (finalize-mentorship-program (mentorship-id uint))
    (let (
            (program (unwrap! (get-mentorship-program mentorship-id)
                err-mentorship-not-found
            ))
            (mentor-fee (get mentor-fee program))
            (mentor-reward (/ (* mentor-fee u80) u100))
            (platform-fee (/ (* mentor-fee u20) u100))
        )
        (map-set mentorship-programs { mentorship-id: mentorship-id }
            (merge program { status: "completed" })
        )

        (try! (as-contract (stx-transfer? (/ mentor-reward u2) tx-sender
            (get mentor-partner-1 program)
        )))
        (try! (as-contract (stx-transfer? (/ mentor-reward u2) tx-sender
            (get mentor-partner-2 program)
        )))

        (var-set contract-balance (+ (var-get contract-balance) platform-fee))

        (ok true)
    )
)

(define-public (update-mentor-availability
        (mentor-couple-id uint)
        (available bool)
    )
    (let ((mentor-profile (unwrap! (get-mentor-profile mentor-couple-id) err-invalid-mentor)))
        (asserts!
            (or
                (is-eq tx-sender (get partner-1 mentor-profile))
                (is-eq tx-sender (get partner-2 mentor-profile))
            )
            err-unauthorized
        )

        (map-set mentor-profiles { mentor-couple-id: mentor-couple-id }
            (merge mentor-profile { available: available })
        )
        (ok true)
    )
)
