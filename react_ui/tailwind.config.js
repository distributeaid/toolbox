const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  theme: {
    extend: {
      boxShadow: {
        'button': '3px 3px 0 #222',
        'button-darkgrey': '3px 3px 0 grey',
        'button-pink': '3px 3px 0 pink',
        'button-white': '3px 3px 0 white',
      },
      fontFamily: {
        sans: ['Poppins', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  variants: {},
  plugins: [
    require('tailwindcss'),
    require('autoprefixer'),
    require('@tailwindcss/ui'),
  ],
}
