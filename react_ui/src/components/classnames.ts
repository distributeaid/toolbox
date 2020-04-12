export const classnames = (...classNames: (string | undefined)[]) =>
  classNames.filter((x) => !!x).join(' ')
