import React from 'react'
import { Trans, useTranslation } from 'react-i18next'
import { useHistory } from 'react-router-dom'

import { Button } from '../components/Button'
import { ContentContainer } from '../components/ContentContainer'
import { Divider } from '../components/Divider'
import { Input } from '../components/Input'
import { Select } from '../components/Select'
import { TextLink } from '../components/TextLink'
import countries from '../data/countries.json'
import usStates from '../data/us_states.json'
import {
  Group,
  GroupInput,
  Maybe,
  useCreateChapterMutation,
  useUpdateChapterMutation,
} from '../generated/graphql'

import { Formik, Form } from 'formik'
import * as yup from 'yup'
import { FormInput } from '../components/FormInput'

const initialValues = {
  name: '',
  // description: '',
  // donationForm: '',
  // donationFormResults: '',
  // requestForm: '',
  // requestFormResults: '',
  // volunteerForm: '',
  // volunteerFormResults: '',
}

const isValidGDocsUrl = (requiredBasePath: string, url: URL) => {
  if (url.protocol !== 'http:' && url.protocol !== 'https:') {
    return false
  }

  if (url.hostname !== 'docs.google.com') {
    return false
  }

  return url.pathname.indexOf(requiredBasePath) === 0
}

const validationSchema = yup.object({
  name: yup.string().required('Please enter a chapter name'),
  // description: yup.string().required('Please enter a description'),
  // donationForm: yup
  //   .string()
  //   .url('Donation form link must be a full url (https://example.com)')
  //   .required('Please include the donation form link'),
  // donationFormResults: yup
  //   .string()
  //   .url('Donation form results link must be a full url (https://example.com)')
  //   .when('donationForm', {
  //     is: (value: URL) => isValidGDocsUrl('/form', value),
  //     then: (value: URL) => isValidGDocsUrl('/spreadsheets', value),
  //   })
  //   .typeError(
  //     'Donation form results URL must be a Google spreadsheet if donation form is a Google form'
  //   ),
  // requestForm: yup
  //   .string()
  //   .url('Request form link must be a full url (https://example.com)')
  //   .required('Please enter a request form link'),
  // requestFormResults: yup
  //   .string()
  //   .url('Request form results link must be a full url (https://example.com)')
  //   .when('requestForm', {
  //     is: (value: URL) => isValidGDocsUrl('/form', value),
  //     then: (value: URL) => isValidGDocsUrl('/spreadsheets', value),
  //   })
  //   .typeError(
  //     'Request form results URL must be a Google spreadsheet if request form is a Google form'
  //   ),
  // volunteerForm: yup.string().url().required('Please enter a volunteer form'),
  // volunteerFormResults: yup
  //   .string()
  //   .url()
  //   .when('volunteerForm', {
  //     is: (value: URL) => isValidGDocsUrl('/form', value),
  //     then: (value: URL) => isValidGDocsUrl('/spreadsheets', value),
  //   })
  //   .typeError(
  //     'Volunteer form results URL must be a Google spreadsheet if volunteer form is a Google form'
  //   ),
})

type Props = {
  editChapter?: Group
}

const ChapterForm2: React.FC<Props> = ({ editChapter }) => {
  const chapter = editChapter || ({} as Group)
  const isNewChapter = !chapter.id
  const { t } = useTranslation()
  return (
    <Formik
      initialValues={initialValues}
      validationSchema={validationSchema}
      onSubmit={() => {
        // TODO
      }}>
      {() => {
        return (
          <ContentContainer>
            <Form>
              <div className="grid grid-cols-1 gap-4 m-4 md:m-16">
                <h1 className="font-bold text-3xl mb-4">
                  {isNewChapter
                    ? t('chapterForm.newTitle')
                    : t('chapterForm.editTitle')}
                </h1>
                <p>
                  <Trans
                    i18nKey={
                      isNewChapter
                        ? 'chapterForm.topDescriptionNew'
                        : 'chapterForm.topDescriptionEdit'
                    }>
                    placeholder{' '}
                    <TextLink newTab={true} href="/chapters">
                      placeholder link text
                    </TextLink>
                    placeholder end text
                  </Trans>
                </p>
                <Divider />
                <>
                  {sectionHeader(t('chapterForm.chapterName'))}

                  <p>{t('chapterForm.chapterNameDescription')}</p>

                  <FormInput
                    id="chapter-name"
                    type="text"
                    title={t('chapterForm.chapterName') + '*'}
                    name="name"
                  />
                </>
              </div>
            </Form>
          </ContentContainer>
        )
      }}
    </Formik>
  )
}

const isValidUrl = (value: Maybe<string>) => {
  if (value == null) {
    return false
  }

  let url

  try {
    url = new URL(value)
  } catch (_) {
    return false
  }

  if (url.protocol !== 'http:' && url.protocol !== 'https:') {
    return false
  }

  return true
}

const sectionHeader = (contents: string) => (
  <h2 className="font-bold text-xl mt-4">{contents}</h2>
)

const VALID_CHAPTER_NAME_REGEX = /^[a-zA-Z \-,()]*$/

type ChapterNameProps = {
  t: (key: string) => string
  chapterName: string
  setChapterName: (chapterName: string) => void
}

const ChapterNameSection: React.FC<ChapterNameProps> = ({
  t,
  chapterName,
  setChapterName,
}) => {
  const onChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = event.target.value

    if (VALID_CHAPTER_NAME_REGEX.test(newValue)) {
      setChapterName(newValue)
    }
  }

  return (
    <>
      {sectionHeader(t('chapterForm.chapterName'))}

      <p>{t('chapterForm.chapterNameDescription')}</p>

      <Input
        id="chapter-name"
        type="text"
        title={t('chapterForm.chapterName') + '*'}
        onChange={onChange}
        value={chapterName}
      />
    </>
  )
}

const VALID_CHAPTER_SLUG_REGEX = /^[a-zA-Z-]*$/

type ChapterSlugProps = {
  t: (key: string) => string
  chapterSlug: string
  setChapterSlug: (chapterSlug: string) => void
}

const ChapterSlugSection: React.FC<ChapterSlugProps> = ({
  t,
  chapterSlug,
  setChapterSlug,
}) => {
  const onChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = event.target.value

    if (VALID_CHAPTER_SLUG_REGEX.test(newValue)) {
      setChapterSlug(newValue)
    }
  }

  return (
    <>
      {sectionHeader(t('chapterForm.chapterSlug'))}

      <p>{t('chapterForm.chapterSlugDescription')}</p>

      <Input
        id="chapter-slug"
        type="text"
        title={t('chapterForm.chapterSlug') + '*'}
        onChange={onChange}
        value={chapterSlug}
      />

      <p>
        <span className="font-bold mb-1">The URL for the chapter</span>

        <span className="font-mono">local.masksfordocs.com/{chapterSlug}</span>
      </p>
    </>
  )
}

type ChapterLocationProps = {
  t: (key: string) => string
  chapterCountry: string
  setChapterCountry: (chapterCountry: string) => void
  chapterProvince: string
  setChapterProvince: (chapterProvince: string) => void
  chapterPostalCode: string
  setChapterPostalCode: (chapterPostalCode: string) => void
}

const ChapterLocationSection: React.FC<ChapterLocationProps> = ({
  t,
  chapterCountry,
  setChapterCountry,
  chapterProvince,
  setChapterProvince,
  chapterPostalCode,
  setChapterPostalCode,
}) => {
  const onCountrySelect = (event: React.ChangeEvent<HTMLSelectElement>) => {
    const value = event.target.value

    setChapterCountry(value)

    if (!value) {
      setChapterProvince('')
      setChapterPostalCode('')
    }
  }

  const onProvinceSelect = (event: React.ChangeEvent<HTMLSelectElement>) =>
    setChapterProvince(event.target.value)

  const onProvinceChange = (event: React.ChangeEvent<HTMLInputElement>) =>
    setChapterProvince(event.target.value)

  const onPostalCodeChange = (event: React.ChangeEvent<HTMLInputElement>) =>
    setChapterPostalCode(event.target.value)

  const showStateSelect = chapterCountry === 'US'
  const showProvinceInput = !showStateSelect && chapterCountry !== ''
  const showPostalCodeInput = showStateSelect || showProvinceInput

  return (
    <>
      {sectionHeader(t('chapterForm.chapterLocation'))}

      <Select
        label={t('terms.country') + '*'}
        value={chapterCountry}
        onChange={onCountrySelect}
        includeBlank={true}
        options={countries.map((country: { name: string; code: string }) => (
          <option key={country.code} value={country.code}>
            {country.name}
          </option>
        ))}
      />

      {showStateSelect && (
        <Select
          label={t('terms.state') + '*'}
          value={chapterProvince}
          onChange={onProvinceSelect}
          includeBlank={true}
          options={usStates.map((state: { name: string; code: string }) => (
            <option key={state.code} value={state.code}>
              {state.name}
            </option>
          ))}
        />
      )}

      {showProvinceInput && (
        <Input
          id="province"
          type="text"
          title={t('terms.province') + '*'}
          onChange={onProvinceChange}
          value={chapterProvince}
        />
      )}

      {showPostalCodeInput && (
        <div>
          <p className="mt-2">
            Note: the postal code will not be displayed publicly. It's for
            internal use only.
          </p>

          <Input
            id="postal-code"
            type="text"
            title={t('terms.postalCode') + '*'}
            onChange={onPostalCodeChange}
            value={chapterPostalCode}
          />
        </div>
      )}
    </>
  )
}

type ChapterDescriptionSectionProps = {
  t: (key: string) => string
  chapterDescription: string
  setChapterDescription: (value: string) => void
}

const ChapterDescriptionSection: React.FC<ChapterDescriptionSectionProps> = ({
  t,
  chapterDescription,
  setChapterDescription,
}) => {
  const onDescriptionChange = (event: React.ChangeEvent<HTMLTextAreaElement>) =>
    setChapterDescription(event.target.value)

  return (
    <>
      {sectionHeader(t('chapterForm.chapterDescriptionHeader'))}

      <label>
        {t('terms.description') + '*'}

        <div>
          <textarea
            className="w-full h-40 border border-gray-300 rounded-md placeholder-gray-400 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 transition duration-150 ease-in-out sm:text-sm"
            id="postal-code"
            onChange={onDescriptionChange}
            value={chapterDescription}
          />
        </div>
      </label>
    </>
  )
}

type ChapterFormLinksSectionProps = {
  t: (key: string) => string
  chapterVolunteerFormLink: string
  chapterVolunteerResultsLink: string
  setChapterVolunteerFormLink: (value: string) => void
  setChapterVolunteerResultsLink: (value: string) => void
  chapterRequestFormLink: string
  chapterRequestResultsLink: string
  setChapterRequestFormLink: (value: string) => void
  setChapterRequestResultsLink: (value: string) => void
  chapterDonateFormLink: string
  chapterDonateResultsLink: string
  setChapterDonateFormLink: (value: string) => void
  setChapterDonateResultsLink: (value: string) => void
}

const ChapterFormLinksSection: React.FC<ChapterFormLinksSectionProps> = ({
  t,
  chapterVolunteerFormLink,
  chapterVolunteerResultsLink,
  setChapterVolunteerFormLink,
  setChapterVolunteerResultsLink,
  chapterRequestFormLink,
  chapterRequestResultsLink,
  setChapterRequestFormLink,
  setChapterRequestResultsLink,
  chapterDonateFormLink,
  chapterDonateResultsLink,
  setChapterDonateFormLink,
  setChapterDonateResultsLink,
}) => {
  const urlOnChange = (setter: (value: string) => void) => (
    event: React.ChangeEvent<HTMLInputElement>
  ) => setter(event.target.value)

  return (
    <>
      {sectionHeader(t('chapterForm.chapterFormLinksHeader'))}

      <h3 className="font-bold text-lg mt-2">
        {t('chapterForm.requestFormHeader')}
      </h3>

      <Input
        id="request-form-link"
        type="text"
        title={t('chapterForm.requestFormInputLabel') + '*'}
        onChange={urlOnChange(setChapterRequestFormLink)}
        value={chapterRequestFormLink}
      />

      <Input
        id="request-results-link"
        type="text"
        title={t('chapterForm.requestResultsInputLabel')}
        onChange={urlOnChange(setChapterRequestResultsLink)}
        value={chapterRequestResultsLink}
      />

      <h3 className="font-bold text-lg mt-2">
        {t('chapterForm.donationFormHeader')}
      </h3>

      <Input
        id="donate-form-link"
        type="text"
        title={t('chapterForm.donateFormInputLabel') + '*'}
        onChange={urlOnChange(setChapterDonateFormLink)}
        value={chapterDonateFormLink}
      />

      <Input
        id="donate-results-link"
        type="text"
        title={t('chapterForm.donateResultsInputLabel')}
        onChange={urlOnChange(setChapterDonateResultsLink)}
        value={chapterDonateResultsLink}
      />

      <h3 className="font-bold text-lg mt-2">
        {t('chapterForm.volunteerFormHeader')}
      </h3>

      <Input
        id="volunteer-form-link"
        type="text"
        title={t('chapterForm.volunteerFormInputLabel') + '*'}
        onChange={urlOnChange(setChapterVolunteerFormLink)}
        value={chapterVolunteerFormLink}
      />

      <Input
        id="volunteer-results-link"
        type="text"
        title={t('chapterForm.volunteerResultsInputLabel')}
        onChange={urlOnChange(setChapterVolunteerResultsLink)}
        value={chapterVolunteerResultsLink}
      />
    </>
  )
}

const validateChapterArgs = (chapterArgs: GroupInput): string[] => {
  const errors: string[] = []

  const requiredValues: Array<keyof GroupInput> = [
    'name',
    'description',
    'donationForm',
    'requestForm',
    'volunteerForm',
  ]

  requiredValues.forEach((key: keyof GroupInput) => {
    if (!chapterArgs[key]) {
      errors.push(key + ' is required.')
    }
  })

  const resultsUrlNotSpreadsheetMessage = (formName: string) =>
    `${formName} form results URL must be a google spreadsheet if ${formName} is a google form.`

  if (!isValidUrl(chapterArgs.donationForm)) {
    errors.push('Donation form link must be a full url (https://example.com)')
  }
  if (!isValidUrl(chapterArgs.volunteerForm)) {
    errors.push('Volunteer form link must be a full url (https://example.com)')
  }
  if (!isValidUrl(chapterArgs.requestForm)) {
    errors.push('Request form link must be a full url (https://example.com)')
  }

  return errors
}

type ChapterFormProps = {
  editChapter?: Group
}

// This form was written quickly to unblock the Masks For Docs project timeline.
// It is regrettably not very maintainable and generally packs much too much
// logic into a single file. It also maintains two mutation hooks, one for
// edit and one for new, at the same time regardless of which use of the form
// is actually taking place.
//
// Please feel free to re-use as little of this code as necessary when
// refactoring into hopefully something more reasonable.
export const ChapterForm: React.FC<ChapterFormProps> = ({ editChapter }) => {
  const chapter = editChapter || ({} as Group)
  const isNewChapter = !chapter.id

  const { t } = useTranslation()
  const history = useHistory()
  const [errorMessages, setErrorMessages] = React.useState<Array<string>>([])

  const [chapterName, setChapterName] = React.useState(chapter.name || '')
  const [chapterSlug, setChapterSlug] = React.useState('')
  const [chapterCountry, setChapterCountry] = React.useState('')
  const [chapterProvince, setChapterProvince] = React.useState('')
  const [chapterPostalCode, setChapterPostalCode] = React.useState('')
  const [chapterDescription, setChapterDescription] = React.useState(
    chapter.description || ''
  )
  const [
    chapterVolunteerFormLink,
    setChapterVolunteerFormLink,
  ] = React.useState(chapter.volunteerForm || '')
  const [
    chapterVolunteerResultsLink,
    setChapterVolunteerResultsLink,
  ] = React.useState(chapter.volunteerFormResults || '')
  const [chapterRequestFormLink, setChapterRequestFormLink] = React.useState(
    chapter.volunteerFormResults || ''
  )
  const [
    chapterRequestResultsLink,
    setChapterRequestResultsLink,
  ] = React.useState(chapter.requestFormResults || '')
  const [chapterDonateFormLink, setChapterDonateFormLink] = React.useState(
    chapter.donationForm || ''
  )
  const [
    chapterDonateResultsLink,
    setChapterDonateResultsLink,
  ] = React.useState(chapter.donationFormResults || '')

  const chapterArgs: GroupInput = {
    description: chapterDescription,
    donationForm: chapterDonateFormLink,
    donationFormResults: chapterDonateResultsLink,
    donationLink: null,
    name: chapterName,
    requestForm: chapterRequestFormLink,
    requestFormResults: chapterRequestResultsLink,
    slackChannelName: null,
    slug: chapterSlug,
    volunteerForm: chapterVolunteerFormLink,
    volunteerFormResults: chapterVolunteerResultsLink,
  }

  const onCompleted = () => history.push('/chapters')

  const [
    createChapterMutation,
    { loading: createLoading, error: createError },
  ] = useCreateChapterMutation({
    variables: { groupInput: chapterArgs },
    onCompleted,
  })

  const [
    updateChapterMutation,
    { loading: updateLoading, error: updateError },
  ] = useUpdateChapterMutation({
    variables: { groupInput: chapterArgs, id: chapter.id },
    onCompleted,
  })

  const loading = createLoading || updateLoading
  const error = createError || updateError

  const submit = () => {
    const errorMessages: string[] = validateChapterArgs(chapterArgs)

    if (errorMessages.length === 0) {
      isNewChapter ? createChapterMutation() : updateChapterMutation()
    } else {
      setErrorMessages(errorMessages)
    }
  }

  return (
    <ContentContainer>
      <ChapterForm2 editChapter={editChapter} />
      <div className="grid grid-cols-1 gap-4 m-4 md:m-16">
        <h1 className="font-bold text-3xl mb-4">
          {isNewChapter
            ? t('chapterForm.newTitle')
            : t('chapterForm.editTitle')}
        </h1>

        <p>
          <Trans
            i18nKey={
              isNewChapter
                ? 'chapterForm.topDescriptionNew'
                : 'chapterForm.topDescriptionEdit'
            }>
            placeholder{' '}
            <TextLink newTab={true} href="/chapters">
              placeholder link text
            </TextLink>
            placeholder end text
          </Trans>
        </p>

        <Divider />

        <ChapterNameSection
          t={t}
          chapterName={chapterName}
          setChapterName={setChapterName}
        />

        <ChapterSlugSection
          t={t}
          chapterSlug={chapterSlug}
          setChapterSlug={setChapterSlug}
        />

        <ChapterLocationSection
          t={t}
          chapterCountry={chapterCountry}
          setChapterCountry={setChapterCountry}
          chapterProvince={chapterProvince}
          setChapterProvince={setChapterProvince}
          chapterPostalCode={chapterPostalCode}
          setChapterPostalCode={setChapterPostalCode}
        />

        <ChapterDescriptionSection
          t={t}
          chapterDescription={chapterDescription}
          setChapterDescription={setChapterDescription}
        />

        <ChapterFormLinksSection
          t={t}
          chapterVolunteerFormLink={chapterVolunteerFormLink}
          chapterVolunteerResultsLink={chapterVolunteerResultsLink}
          setChapterVolunteerFormLink={setChapterVolunteerFormLink}
          setChapterVolunteerResultsLink={setChapterVolunteerResultsLink}
          chapterRequestFormLink={chapterRequestFormLink}
          chapterRequestResultsLink={chapterRequestResultsLink}
          setChapterRequestFormLink={setChapterRequestFormLink}
          setChapterRequestResultsLink={setChapterRequestResultsLink}
          chapterDonateFormLink={chapterDonateFormLink}
          chapterDonateResultsLink={chapterDonateResultsLink}
          setChapterDonateFormLink={setChapterDonateFormLink}
          setChapterDonateResultsLink={setChapterDonateResultsLink}
        />

        <Divider outerClasses="my-6" />

        {errorMessages.map((message: string, i: number) => (
          <div key={i}>{message}</div>
        ))}

        {error && <div>server error: {error}</div>}

        <Button onClick={submit}>Submit</Button>

        {loading && (
          <div>
            {isNewChapter ? 'creating chapter...' : 'updating chapter...'}
          </div>
        )}
      </div>
    </ContentContainer>
  )
}
