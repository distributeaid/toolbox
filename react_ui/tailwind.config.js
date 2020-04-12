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
        heading: ['Poppins', ...defaultTheme.fontFamily.sans],
        body: ['Open Sans', ...defaultTheme.fontFamily.sans],
        mono: ['PT Mono', ...defaultTheme.fontFamily.mono],
      },
      boxShadow: {
        button: '0.25rem 0.25rem 0 black'
      }
    },
  },
  variants: {},
  plugins: [
    require('tailwindcss'),
    require('autoprefixer'),
    require('@tailwindcss/ui'),
  ],
}
