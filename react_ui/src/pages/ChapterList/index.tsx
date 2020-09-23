import React from 'react'
import { Trans, useTranslation } from 'react-i18next'

import { Background } from '../../components/Background'
import { ContentContainer } from '../../components/ContentContainer'
import { FAQFooter } from '../../components/FAQFooter'
import { MainContent } from '../../components/MainContent'
import { MainHeader } from '../../components/MainHeader'
import { PreHeader } from '../../components/PreHeader'
import { Group, Maybe, useGetChapterListQuery } from '../../generated/graphql'
import { ChaptersInCountry } from './ChaptersInCountry'
import { groupChaptersByCountry } from './utils'

export const ChapterList: React.FC = () => {
  const { t } = useTranslation()

  const { loading, error, data } = useGetChapterListQuery()

  if (loading || !data?.groups) {
    return null
  }

  if (error) {
    return <div>{error.toString()}</div>
  }

  const { groups: chapters } = data

  const chaptersByCountry = groupChaptersByCountry(
    (chapters as Maybe<Group>[]).filter(
      (chapter): chapter is Group => !!chapter
    )
  )

  const alphabetizedChaptersByCountry = chaptersByCountry.map((country) => {
    country.chapters.sort((a, b) =>
      a.name.toLowerCase().localeCompare(b.name.toLowerCase())
    )
    return country
  })

  return (
    <MainContent>
      <Background />
      <ContentContainer>
        <div className="md:w-7/12 pt-16 sm:pt-32">
          <MainHeader>{t('chapterList.title')}</MainHeader>

          <PreHeader>
            <Trans i18nKey="chapterList.subtitle">
              Connect locally to get what you need and give what you can. Find
              your local chapter below to{' '}
              <strong className="font-semibold">request supplies</strong>,{' '}
              <strong className="font-semibold">donate supplies</strong>, or{' '}
              <strong className="font-semibold">volunteer</strong>
            </Trans>
          </PreHeader>
        </div>
      </ContentContainer>

      <div className="border-gray-400 border-t w-full bg-lightBlue mt-20 py-20">
        {alphabetizedChaptersByCountry.map((cwc) => (
          <ChaptersInCountry
            key={cwc.countryCode}
            t={t}
            countryWithChapters={cwc}
          />
        ))}

        <ContentContainer>
          <FAQFooter />
        </ContentContainer>
      </div>
    </MainContent>
  )
}
