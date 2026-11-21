import { Controller } from "@hotwired/stimulus"

// Moving pictures play while they are on the wall in front of you and hold
// still once they are not.
//
// A project screen is one long horizontal row with every work in the document
// at once, and a browser will happily decode a video that is six screens off
// to the right. Left alone, a project of twenty videos plays twenty videos,
// forever, nineteen of them where nobody is looking. So nothing carries
// `autoplay`; this does it, for whatever is actually in view.

export default class extends Controller {
  connect() {
    // Autoplay is motion, and the site takes that preference seriously
    // elsewhere. Where it's set, the videos sit on their first frame with the
    // controls to start them by hand.
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      this.videos.forEach((video) => { video.controls = true })
      return
    }

    if (!("IntersectionObserver" in window)) return this.videos.forEach((video) => this.play(video))

    // A little margin so a video is already running by the time it has been
    // scrolled to, rather than starting under the viewer's eye.
    this.observer = new IntersectionObserver(
      (entries) => entries.forEach((entry) => this.toggle(entry)),
      { rootMargin: "100px", threshold: 0.1 }
    )
    this.videos.forEach((video) => this.observer.observe(video))
  }

  disconnect() {
    this.observer?.disconnect()
    this.videos.forEach((video) => video.pause())
  }

  get videos() {
    return Array.from(this.element.querySelectorAll("video"))
  }

  toggle({ target, isIntersecting }) {
    isIntersecting ? this.play(target) : target.pause()
  }

  // A play() the browser refuses -- an autoplay policy, or a pause() landing
  // before it resolves -- rejects, and there is nothing useful to do about it
  // beyond not letting it reach the console as an unhandled rejection.
  play(video) {
    video.play().catch(() => {})
  }
}
