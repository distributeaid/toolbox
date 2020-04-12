import React from 'react'
import { useTranslation } from 'react-i18next'

import { Background } from '../components/Background'
import { BackLink } from '../components/BackLink'
import { BorderBlock } from '../components/BorderBlock'
import { ContentContainer } from '../components/ContentContainer'
import { MainContent } from '../components/MainContent'
import { MainHeader } from '../components/MainHeader'
import { P } from '../components/P'
import { PreHeader } from '../components/PreHeader'
import { ShadowButtonLink } from '../components/ShadowButtonLink'
import { useGetChapterBySlugQuery } from '../generated/graphql'

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
            <PreHeader>California — USA</PreHeader>

            <MainHeader>{chapter.name}</MainHeader>
          </>
        )}
      </ContentContainer>

      {chapter && (
        <>
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
        </>
      )}

      <ContentContainer>
        <div className="flex flex-col justify-center py-10 sm:py-20">
          <h2 className="text-center font-heading font-semibold text-2xl sm:text-5xl leading-loose mb-4">
            {t('chapter.faqHeader')}
          </h2>

          <ShadowButtonLink className="bg-blue-600 sm:w-auto" to="/faq">
            {t('chapter.faqLink')}
          </ShadowButtonLink>
        </div>
      </ContentContainer>
    </MainContent>
  )
}
