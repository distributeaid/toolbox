export const classnames = (...classNames: (string | undefined | boolean)[]) =>
  classNames.filter((x) => !!x).join(' ')
