import { Animation, PageTransition } from 'ionic-angular';

export class myLeaveAnimation extends PageTransition {

  public init() {
    const ele = this.leavingView.pageRef().nativeElement;
    const contentWrapper = new Animation(this.plt, ele.querySelector('.wrapper'));
    const wrapper = new Animation(this.plt, ele.querySelector('.modal-wrapper'));
    

    wrapper.beforeStyles({ 'transform': 'scale(0)', 'opacity': 1 });
    wrapper.fromTo('translateY', '0%', '-100%');
    wrapper.fromTo('opacity', 1, 1);
    contentWrapper.fromTo('opacity', 0.4, 0.0);

    this
      .element(this.leavingView.pageRef())
      .duration(400)
      .easing('ease-out')
      .add(contentWrapper)
      .add(wrapper);
  }
}