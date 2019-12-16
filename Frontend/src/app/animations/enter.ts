import { Animation, PageTransition } from 'ionic-angular';

export class myEnterAnimation extends PageTransition {

public init() {
    const ele = this.enteringView.pageRef().nativeElement;
    const wrapper = new Animation(this.plt, ele.querySelector('.modal-wrapper'));

    wrapper.beforeStyles({ 'opacity': 1 })
    .fromTo('translateY', '-100%', '0%');
    // wrapper.fromTo('transform', 'scale(0)', 'scale(1.0)');
    // wrapper.fromTo('opacity', 1, 1);

    this
        .element(this.enteringView.pageRef())
        .duration(400)
        .easing('cubic-bezier(0.36,0.66,0.04,1)')
        .add(wrapper);
}
}