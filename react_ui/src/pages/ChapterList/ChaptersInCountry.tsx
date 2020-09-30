import React from 'react'
import { Trans } from 'react-i18next'

import { P } from '../../components/P'
import { countryCodeToName } from '../../util/placeCodeToName'
import { ChapterItem } from './ChapterItem'
import { CountryWithChapters, provinceLocalName } from './utils'

export const ChaptersInCountry: React.FC<{
  t: (key: string) => string
  countryWithChapters: CountryWithChapters
}> = ({ countryWithChapters, t }) => (
  <div className="container p-6 pb-12 last:pb-6 md:mx-auto w-full max-w-4xl">
    <div className="grid grid-cols-1 gap-2">
      <h3 className="font-heading text-3xl font-semibold px-6">
        {countryCodeToName(countryWithChapters.countryCode)}
      </h3>

      <div className="flex px-6 font-heading font-semibold text-lg text-blue-600">
        <div className="w-4/12 pb-0">
          {provinceLocalName(countryWithChapters.countryCode)}
        </div>

        <div className="w-6/12 pb-0">{t('chapterList.chapterName')}</div>
      </div>

      <ul>
        {countryWithChapters.chapters.map((g) => (
          <ChapterItem key={g.id} chapter={g} />
        ))}
      </ul>
    </div>

    <P className="text-center mx-auto pt-6 w-2/3 sm:w-1/2">
      <Trans i18nKey="chapterList.cta">
        Don’t see your local chapter? Reach out to{' '}
        <a
          href="https://share.hsforms.com/1ZEAK2ikxSFKqR_XR7J-x5Q4dh7j"
          className="underline text-blue-600"
          target="_blank"
          rel="noopener noreferrer">
          request supplies
        </a>
        ,{' '}
        <a
          href="https://share.hsforms.com/19adMT7wKRNSvxJSYJHOdGw4dh7j"
          className="underline text-blue-600"
          target="_blank"
          rel="noopener noreferrer">
          donate supplies
        </a>
        , or{' '}
        <a
          href="https://share.hsforms.com/1wEiqrs4DTQGBBQ9z2wBg8Q4dh7j"
          className="underline text-blue-600"
          target="_blank"
          rel="noopener noreferrer">
          volunteer
        </a>
        .
      </Trans>
    </P>
  </div>
)
