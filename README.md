# PBPopinController

Custom controller that pops from the bottom, exactly like keyboard.

![GIF Image](https://raw.githubusercontent.com/pronebird/PBPopinController/master/README%20Images/PopinController.gif)

Features:

1. Content controller support.
2. Non-modal, creates its own UIWindow and passes through all user interactions within unoccupied by content area.
3. Plays nice with keyboard, e.g. hides itself if keyboard shows up, and vise-versa.
4. Dismisses on scroll if presented from table or collection view controller.
5. Uses same animation curve and duration as keyboard.
6. Knows how to swap content controller if already presented, without unnecessary animations.
7. Works with storyboards, use custom `PBPopinSegue`.

Known issues and what needs to be fixed:

1. May get stuck when presented and dismissed too fast. Race condition.
2. Orientation changes aren't handled.
3. Unwinding does not work. Manually dismiss controller.
4. Does not dismiss itself if presenting controller dismissed. Dismiss manually.

All contributions, PRs, comments are welcome!

