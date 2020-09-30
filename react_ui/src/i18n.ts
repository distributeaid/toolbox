import i18n from 'i18next'
import LanguageDetector from 'i18next-browser-languagedetector'
import Backend from 'i18next-http-backend'
import { initReactI18next } from 'react-i18next'

i18n
  .use(Backend)
  .use(LanguageDetector)
  // passes i18n down to react-i18next
  .use(initReactI18next)
  .init({
    fallbackLng: 'en',
    // comment back debug when needed for dev, otherwise leave off so console statements don't show up in prod
    // debug: true,

    interpolation: {
      escapeValue: false, // react already safe from xss
    },
  })

// Note: console will show "GET http://localhost:3000/locales/en-US/translation.json 404 (Not Found)," but i18next still works. We believe it's a timing bug.

export default i18n
