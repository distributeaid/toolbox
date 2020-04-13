import { Form, Formik } from 'formik'
import React from 'react'
import { Trans, useTranslation } from 'react-i18next'
import { useHistory } from 'react-router-dom'

import { Button } from '../../components/Button'
import { ContentContainer } from '../../components/ContentContainer'
import { Divider } from '../../components/Divider'
import { FormInput } from '../../components/FormInput'
import { FormSelect } from '../../components/FormSelect'
import { FormTextarea } from '../../components/FormTextarea'
import { TextLink } from '../../components/TextLink'
import countries from '../../data/countries.json'
import usStates from '../../data/us_states.json'
import {
  Group,
  useCreateChapterMutation,
  useUpdateChapterMutation,
} from '../../generated/graphql'
import { initialValues } from './initialValues'
import { sectionHeader } from './sectionHeader'
import { validationSchema } from './validationSchema'

type Props = {
  editChapter?: Group
}

export const ChapterForm: React.FC<Props> = ({ editChapter }) => {
  const chapter = editChapter || ({} as Group)
  const isNewChapter = !chapter.id
  const { t } = useTranslation()
  const history = useHistory()

  const [
    createChapterMutation,
    { loading: createLoading, error: createError },
  ] = useCreateChapterMutation({
    onCompleted: () => history.push('/chapters'),
  })

  const [
    updateChapterMutation,
    { loading: updateLoading, error: updateError },
  ] = useUpdateChapterMutation({
    onCompleted: () => history.push('/chapters'),
  })

  const loading = createLoading || updateLoading
  const error = createError || updateError

  return (
    <Formik
      initialValues={initialValues}
      validationSchema={validationSchema}
      onSubmit={(values) => {
        const groupInput = {
          description: values.description,
          donationForm: values.donationForm,
          donationFormResults: values.donationFormResults,
          donationLink: null,
          name: values.name,
          requestForm: values.requestForm,
          requestFormResults: values.requestFormResults,
          slackChannelName: null,
          slug: values.slug,
          volunteerForm: values.volunteerForm,
          volunteerFormResults: values.volunteerFormResults,
        }
        isNewChapter
          ? createChapterMutation({ variables: { groupInput } })
          : updateChapterMutation({ variables: { groupInput, id: chapter.id } })
      }}>
      {({ values }) => {
        const showStateSelect = values.country === 'US'
        const showProvinceInput = !showStateSelect && values.country !== ''
        const showPostalCodeInput = showStateSelect || showProvinceInput

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
                {sectionHeader(t('chapterForm.chapterName'))}
                <p>{t('chapterForm.chapterNameDescription')}</p>
                <FormInput
                  name="name"
                  title={t('chapterForm.chapterName') + '*'}
                />

                {sectionHeader(t('chapterForm.chapterSlug'))}
                <p>{t('chapterForm.chapterSlugDescription')}</p>
                <FormInput
                  name="slug"
                  title={t('chapterForm.chapterSlug') + '*'}
                />
                <p>
                  <span className="font-bold mb-1">
                    The URL for the chapter:{' '}
                  </span>
                  <span className="font-mono">
                    local.masksfordocs.com/{values.slug}
                  </span>
                </p>

                {sectionHeader(t('chapterForm.chapterLocation'))}
                <FormSelect
                  name="country"
                  label={t('terms.country') + '*'}
                  options={countries.map((country) => ({
                    name: country.name,
                    value: country.code,
                  }))}
                  value={values.country}
                  includeBlank
                />
                {showStateSelect && (
                  <FormSelect
                    name="state"
                    label={t('terms.state') + '*'}
                    options={usStates.map((state) => ({
                      name: state.name,
                      value: state.code,
                    }))}
                    value={values.state}
                    includeBlank
                  />
                )}
                {showProvinceInput && (
                  <FormInput
                    name="province"
                    title={t('terms.province') + '*'}
                  />
                )}
                {showPostalCodeInput && (
                  <div>
                    <FormInput
                      name="postalCode"
                      title={t('terms.postalCode') + '*'}
                    />
                    <p className="mt-2">
                      Note: the postal code will not be displayed publicly. It's
                      for internal use only.
                    </p>
                  </div>
                )}

                {sectionHeader(t('chapterForm.chapterDescriptionHeader'))}
                <FormTextarea
                  name="description"
                  title={t('terms.description') + '*'}
                />

                {sectionHeader(t('chapterForm.chapterFormLinksHeader'))}
                <h3 className="font-bold text-lg mt-2">
                  {t('chapterForm.requestFormHeader')}
                </h3>
                <FormInput
                  name="requestForm"
                  title={t('chapterForm.requestFormInputLabel') + '*'}
                />
                <FormInput
                  name="requestFormResults"
                  title={t('chapterForm.requestResultsInputLabel')}
                />
                <h3 className="font-bold text-lg mt-2">
                  {t('chapterForm.donationFormHeader')}
                </h3>
                <FormInput
                  name="donationForm"
                  title={t('chapterForm.donateFormInputLabel') + '*'}
                />
                <FormInput
                  name="donationFormResults"
                  title={t('chapterForm.donateResultsInputLabel')}
                />
                <h3 className="font-bold text-lg mt-2">
                  {t('chapterForm.volunteerFormHeader')}
                </h3>
                <FormInput
                  name="volunteerForm"
                  title={t('chapterForm.volunteerFormInputLabel') + '*'}
                />
                <FormInput
                  name="volunteerFormResults"
                  title={t('chapterForm.volunteerResultsInputLabel')}
                />
                {error && <div>server error: {error}</div>}

                <Button>Submit</Button>

                {loading && (
                  <div>
                    {isNewChapter
                      ? 'Creating chapter...'
                      : 'Updating chapter...'}
                  </div>
                )}
              </div>
            </Form>
          </ContentContainer>
        )
      }}
    </Formik>
  )
}
