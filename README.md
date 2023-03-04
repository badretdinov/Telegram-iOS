# What's done:
#### Animated gradient background and avatar with voice level.
Both hide after 10s delay. 
The gradient background animatedly changes color as the connection changes.
Avatar view pulses during the ring state. And then blinks once.
Avatar is hidden if KeyPreview is displayed.
####  Connection key
Connection key appearance animation after user receive it. Same animation for back button
Expand and reverse animation.
####  Status view
Updated status view state transition.
Layout is updated with new icons.
Progress icon is not animated and should be replaced with lottie animation.
Added new "weak connection" info view.
####  Call button
Updated buttons layout.
Updated transition between on/off states according to design.
####  Rating
Rating view with stars. Basic blink animation is implemented but no advanced selection animation.
Close button design and animations according to design. I used blended color to show "primary" title during the animation and then change it to the mask.
Rating show logic is the same as before but the rate action is not implemented. It will just close the view.

# What isn't:
Optimization of gradient and sound by the proximity sensor
All video tasks. I would use mask layer for that transition from the avatar
Some animation that required lottie files.