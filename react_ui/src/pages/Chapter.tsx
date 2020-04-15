import React from 'react'
import { Helmet } from 'react-helmet'
import { useTranslation } from 'react-i18next'

import { Background } from '../components/Background'
import { BackLink } from '../components/BackLink'
import { BorderBlock } from '../components/BorderBlock'
import { ContentContainer } from '../components/ContentContainer'
import { FAQFooter } from '../components/FAQFooter'
import { MainContent } from '../components/MainContent'
import { MainHeader } from '../components/MainHeader'
import { P } from '../components/P'
import { PreHeader } from '../components/PreHeader'
import { ShadowButtonLink } from '../components/ShadowButtonLink'
import { useGetChapterBySlugQuery } from '../generated/graphql'
import { countryCodeToName, usStateCodeToName } from '../util/placeCodeToName'

type Props = {
  slug: string
}

export const Chapter: React.FC<Props> = ({ slug }) => {
  const { t } = useTranslation()
  const { loading, error, data } = useGetChapterBySlugQuery({
    variables: { slug },
  })

  const chapter = loading || error ? undefined : data?.groupBySlug

  return (
    <MainContent>
      <Background />

      <ContentContainer>
        <div className="pb-16 sm:pb-32">
          <BackLink to="/chapters">{t('chapter.backLink')}</BackLink>
        </div>

        {loading && <div>Loading...</div>}
        {error && <PreHeader>Chapter "{slug}" not found</PreHeader>}
        {chapter && (
          <>
            <Helmet>
              <meta
                property="og:title"
                content={`Masks For Docs – ${chapter.name}`}></meta>
            </Helmet>
            <PreHeader>
              {chapter.location.countryCode === 'US'
                ? usStateCodeToName(chapter.location.province)
                : chapter.location.province}{' '}
              — {countryCodeToName(chapter.location.countryCode)}
            </PreHeader>

            <MainHeader>{chapter.name}</MainHeader>
            {chapter.leader && (
              <div className="mb-8">
                <div className="font-body text-gray-500 text-xs">
                  {t('chapter.leadHeader')}
                </div>
                <div className="font-body text-lg font-bold">
                  {chapter.leader}
                </div>
              </div>
            )}
          </>
        )}
      </ContentContainer>

      {chapter && (
        <BorderBlock>
          <ContentContainer>
            <div className="sm:flex py-6 sm:py-12">
              <P
                className="sm:w-7/12 pb-6 whitespace-pre-line"
                data-testid="description">
                {chapter.description}
              </P>

              <div className="sm:w-5/12 sm:pr-2 z-30">
                {chapter.requestForm && (
                  <ShadowButtonLink
                    external={true}
                    className="bg-blue-600 w-full mb-8"
                    to={chapter.requestForm}>
                    {t('chapter.requestSuppliesLink')}
                  </ShadowButtonLink>
                )}

                {chapter.donationForm && (
                  <ShadowButtonLink
                    external={true}
                    className="bg-red-600 w-full mb-8"
                    to={chapter.donationForm}>
                    {t('chapter.donateSuppliesLink')}
                  </ShadowButtonLink>
                )}

                {chapter.volunteerForm && (
                  <ShadowButtonLink
                    external={true}
                    className="bg-purple-600 w-full"
                    to={chapter.volunteerForm}>
                    {t('chapter.volunteerLink')}
                  </ShadowButtonLink>
                )}
              </div>
            </div>
          </ContentContainer>
        </BorderBlock>
      )}

      <ContentContainer>
        <FAQFooter />
      </ContentContainer>
    </MainContent>
  )
}
