#lang racket

#|

TODO:
- Score
- Moving ship
|#

(require 2htdp/universe 2htdp/image)
(require "util.rkt")

(struct world (boids) #:transparent)
(struct pos (x y) #:transparent)
(struct boid (pos direction speed size) #:transparent)

(define BIG-BOID 20)
(define NUM-BOIDS 15)

(define TICK-RATE 1/30)
(define WIDTH 800)
(define HEIGHT 600)

;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

(define (new-boid)
  (boid (pos (random WIDTH) (random HEIGHT))
        (random 360)
        (+ 1 (random 2))
        BIG-BOID))

(define (move-pos a-pos a-direction a-speed)
  (define r (degrees->radians a-direction))
  (pos (+ (pos-x a-pos) (* a-speed (cos r)))
       (+ (pos-y a-pos) (* a-speed (sin r)))))

(define (wrap-pos a-pos a-size)
  (define x (pos-x a-pos))
  (define y (pos-y a-pos))
  (pos (cond
         [(> x (+ WIDTH a-size)) (- 0 a-size)]
         [(< x (- 0 a-size)) (+ WIDTH a-size)]
         [else x])
       (cond
         [(> y (+ HEIGHT a-size)) (- 0 a-size)]
         [(< y (- 0 a-size)) (+ HEIGHT a-size)]
         [else y])))

(define (move-boid a)
  (boid (wrap-pos
             (move-pos (boid-pos a) (boid-direction a) (boid-speed a))
             (boid-size a))
            (boid-direction a)
            (boid-speed a)
            (boid-size a)))
  
(define (next-world w)
  (define next-boids (world-boids w) )
  (world (map move-boid next-boids)
))

;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;; Rendering

(define (img+scene pos img scene)
  (place-image img (pos-x pos) (pos-y pos) scene))

(define (boids+scene boids scene)
  (foldl (λ (a scene)
           (img+scene (boid-pos a)
                      (circle (boid-size a) "solid" "gray")
                      scene))
         scene boids))

(define (render-world w)
  (boids+scene (world-boids w)                
               (empty-scene WIDTH HEIGHT "black")))

;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

(define (go)
  (big-bang (world (times-repeat NUM-BOIDS (new-boid)))
            (on-tick next-world TICK-RATE)
            (to-draw render-world)))
