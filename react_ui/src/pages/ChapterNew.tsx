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
  GroupInput,
  Maybe,
  useCreateChapterMutation,
} from '../generated/graphql'

const isValidGDocsUrl = (requiredBasePath: string, value: Maybe<string>) => {
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

  if (url.hostname !== 'docs.google.com') {
    return false
  }

  return url.pathname.indexOf(requiredBasePath) === 0
}

const sectionHeader = (contents: string) => (
  <h2 className="font-bold text-xl mt-4">{contents}</h2>
)

const VALID_CHAPTER_NAME_REGEX = /^[a-zA-Z -]*$/

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
  const chapterUrl = chapterName.toLowerCase().trim().replace(/\s+/gi, '-')

  const onChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const newValue = event.target.value

    if (VALID_CHAPTER_NAME_REGEX.test(newValue)) {
      setChapterName(newValue)
    }
  }

  return (
    <>
      {sectionHeader(t('chapterNew.chapterName'))}

      <p>{t('chapterNew.chapterNameDescription')}</p>

      <Input
        id="chapter-name"
        type="text"
        title={t('chapterNew.chapterName') + '*'}
        onChange={onChange}
        value={chapterName}
      />

      {chapterUrl !== '' && (
        <p>
          <span className="font-bold mb-1">The URL for your new chapter</span>

          <br />

          <span className="font-mono">local.masksfordocs.com/{chapterUrl}</span>
        </p>
      )}
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
      {sectionHeader(t('chapterNew.chapterLocation'))}

      <Select
        label={t('terms.country') + '*'}
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
      {sectionHeader(t('chapterNew.chapterDescriptionHeader'))}

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
      {sectionHeader(t('chapterNew.chapterFormLinksHeader'))}

      <h3 className="font-bold text-lg mt-2">
        {t('chapterNew.requestFormHeader')}
      </h3>

      <Input
        id="request-form-link"
        type="text"
        title={t('chapterNew.requestFormInputLabel') + '*'}
        onChange={urlOnChange(setChapterRequestFormLink)}
        value={chapterRequestFormLink}
      />

      <Input
        id="request-results-link"
        type="text"
        title={t('chapterNew.requestResultsInputLabel')}
        onChange={urlOnChange(setChapterRequestResultsLink)}
        value={chapterRequestResultsLink}
      />

      <h3 className="font-bold text-lg mt-2">
        {t('chapterNew.donationFormHeader')}
      </h3>

      <Input
        id="donate-form-link"
        type="text"
        title={t('chapterNew.donateFormInputLabel') + '*'}
        onChange={urlOnChange(setChapterDonateFormLink)}
        value={chapterDonateFormLink}
      />

      <Input
        id="donate-results-link"
        type="text"
        title={t('chapterNew.donateResultsInputLabel')}
        onChange={urlOnChange(setChapterDonateResultsLink)}
        value={chapterDonateResultsLink}
      />

      <h3 className="font-bold text-lg mt-2">
        {t('chapterNew.volunteerFormHeader')}
      </h3>

      <Input
        id="volunteer-form-link"
        type="text"
        title={t('chapterNew.volunteerFormInputLabel') + '*'}
        onChange={urlOnChange(setChapterVolunteerFormLink)}
        value={chapterVolunteerFormLink}
      />

      <Input
        id="volunteer-results-link"
        type="text"
        title={t('chapterNew.volunteerResultsInputLabel')}
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

  if (
    isValidGDocsUrl('/forms', chapterArgs.donationForm) &&
    !isValidGDocsUrl('/spreadsheets', chapterArgs.donationFormResults)
  ) {
    errors.push(resultsUrlNotSpreadsheetMessage('donation'))
  }

  if (
    isValidGDocsUrl('/forms', chapterArgs.volunteerForm) &&
    !isValidGDocsUrl('/spreadsheets', chapterArgs.volunteerFormResults)
  ) {
    errors.push(resultsUrlNotSpreadsheetMessage('voluneer'))
  }

  if (
    isValidGDocsUrl('/forms', chapterArgs.requestForm) &&
    !isValidGDocsUrl('/spreadsheets', chapterArgs.requestFormResults)
  ) {
    errors.push(resultsUrlNotSpreadsheetMessage('request'))
  }

  return errors
}

export const ChapterNew: React.FC = () => {
  const { t } = useTranslation()
  const history = useHistory()
  const [errorMessages, setErrorMessages] = React.useState<Array<string>>([])
  const [chapterName, setChapterName] = React.useState('')
  const [chapterCountry, setChapterCountry] = React.useState('')
  const [chapterProvince, setChapterProvince] = React.useState('')
  const [chapterPostalCode, setChapterPostalCode] = React.useState('')
  const [chapterDescription, setChapterDescription] = React.useState('')
  const [
    chapterVolunteerFormLink,
    setChapterVolunteerFormLink,
  ] = React.useState('')
  const [
    chapterVolunteerResultsLink,
    setChapterVolunteerResultsLink,
  ] = React.useState('')
  const [chapterRequestFormLink, setChapterRequestFormLink] = React.useState('')
  const [
    chapterRequestResultsLink,
    setChapterRequestResultsLink,
  ] = React.useState('')
  const [chapterDonateFormLink, setChapterDonateFormLink] = React.useState('')
  const [
    chapterDonateResultsLink,
    setChapterDonateResultsLink,
  ] = React.useState('')

  const chapterArgs: GroupInput = {
    description: chapterDescription,
    donationForm: chapterDonateFormLink,
    donationFormResults: chapterDonateResultsLink,
    donationLink: null,
    name: chapterName,
    requestForm: chapterRequestFormLink,
    requestFormResults: chapterRequestResultsLink,
    slackChannelName: null,
    volunteerForm: chapterVolunteerFormLink,
    volunteerFormResults: chapterVolunteerResultsLink,
  }

  const [createChapterMutation, { loading, error }] = useCreateChapterMutation({
    variables: {
      groupInput: chapterArgs,
    },
    onCompleted: (responseData) => {
      if (responseData?.createGroup?.slug) {
        history.push('/' + responseData.createGroup.slug)
      }
    },
  })

  const submit = () => {
    const errorMessages: string[] = validateChapterArgs(chapterArgs)

    if (errorMessages.length === 0) {
      createChapterMutation()
    } else {
      setErrorMessages(errorMessages)
    }
  }

  return (
    <ContentContainer>
      <div className="grid grid-cols-1 gap-4 m-4 md:m-16">
        <h1 className="font-bold text-3xl mb-4">{t('chapterNew.title')}</h1>

        <p>
          <Trans i18nKey="chapterNew.topDescription">
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

        <Button onClick={submit}>Create Chapter</Button>

        {loading && <div>creating chapter...</div>}
      </div>
    </ContentContainer>
  )
}
