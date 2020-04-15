const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  theme: {
    extend: {
      boxShadow: {
        'button': '0.25rem 0.25rem 0 #222',
        'button-darkgrey': '0.25rem 0.25rem 0 grey',
        'button-pink': '0.25rem 0.25rem 0 pink',
        'button-white': '0.25rem 0.25rem 0 white',
      },
      fontFamily: {
        heading: ['Poppins', ...defaultTheme.fontFamily.sans],
        body: ['Open Sans', ...defaultTheme.fontFamily.sans],
        mono: ['PT Mono', ...defaultTheme.fontFamily.mono],
      },
      colors: {
        lightBlue: '#F5F6FD',
        pink: '#ed2e69',
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
