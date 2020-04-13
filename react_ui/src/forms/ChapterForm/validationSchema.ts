import * as yup from 'yup'

const isValidGDocsUrl = (requiredBasePath: string, value: string) => {
  let url

  try {
    url = new URL(value)
  } catch (_) {
    return false
  }

  if (url.protocol !== 'http:' && url.protocol !== 'https:') {
    return false
  }

  if (url.hostname !== 'docs.google.com') {
    return false
  }

  return url.pathname.indexOf(requiredBasePath) === 0
}

export const validationSchema = yup.object({
  name: yup
    .string()
    .matches(
      /^[a-zA-Z -]*$/,
      'Chapter name can only contain letters, spaces, and dashes'
    )
    .required('Please enter a chapter name'),
  slug: yup
    .string()
    .matches(/^[a-zA-Z-]*$/, 'Chapter slug can only contain letters and dashes')
    .required('Please enter a chapter slug'),
  country: yup.string().required('Please select a country'),
  state: yup.string().when('country', {
    is: 'US',
    then: yup.string().required('Please select a state'),
  }),
  province: yup.string().when('country', {
    is: (country) => country !== 'US',
    then: yup.string().required('Please enter a province'),
  }),
  postalCode: yup.string().required('Please enter a postal code'),
  description: yup.string().required('Please enter a description'),
  requestForm: yup
    .string()
    .url('Request form link must be a full url (https://example.com)')
    .required('Please enter a request form link'),
  requestFormResults: yup
    .string()
    .url('Request form results link must be a full url (https://example.com)')
    .when('requestForm', {
      is: (value: string) => isValidGDocsUrl('/form', value),
      then: yup
        .string()
        .url(
          'Request form results link must be a full url (https://example.com)'
        )
        .test(
          'is-valid-gdocs-url',
          'Request form results URL must be a Google spreadsheet if request form is a Google form',
          (value: string) => isValidGDocsUrl('/spreadsheets', value)
        ),
    }),
  donationForm: yup
    .string()
    .url('Donation form link must be a full url (https://example.com)')
    .required('Please enter a donation form link'),
  donationFormResults: yup
    .string()
    .url('Donation form results link must be a full url (https://example.com)')
    .when('donationForm', {
      is: (value: string) => isValidGDocsUrl('/form', value),
      then: yup
        .string()
        .url(
          'Donation form results link must be a full url (https://example.com)'
        )
        .test(
          'is-valid-gdocs-url',
          'Donation form results URL must be a Google spreadsheet if donation form is a Google form',
          (value: string) => isValidGDocsUrl('/spreadsheets', value)
        ),
    }),
  volunteerForm: yup.string().url().required('Please enter a volunteer form'),
  volunteerFormResults: yup
    .string()
    .url()
    .when('volunteerForm', {
      is: (value: string) => isValidGDocsUrl('/form', value),
      then: yup
        .string()
        .url(
          'Volunteer form results link must be a full url (https://example.com)'
        )
        .test(
          'is-valid-gdocs-url',
          'Volunteer form results URL must be a Google spreadsheet if volunteer form is a Google form',
          (value: string) => isValidGDocsUrl('/spreadsheets', value)
        ),
    }),
})
