module.exports = function(ctx) {
  if (ctx.build.platform === 'ios' || ctx.build.platform === 'android' ) {
    // Do cordova Specific things
  }
};
