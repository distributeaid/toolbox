import { Group } from '../../generated/graphql'
import { usStateCodeToName } from '../../util/placeCodeToName'

export type CountryWithChapters = {
  countryCode: string
  chapters: Group[]
}

export const groupChaptersByCountry = (
  chapters: Group[]
): CountryWithChapters[] => {
  const chaptersByCountry: { [country: string]: Group[] } = {}

  for (const chapter of chapters) {
    const { countryCode } = chapter.location
    if (!chaptersByCountry[countryCode]) {
      chaptersByCountry[countryCode] = []
    }

    chaptersByCountry[countryCode].push(chapter)
  }

  return Object.keys(chaptersByCountry)
    .map((countryCode) => ({
      countryCode,
      chapters: chaptersByCountry[countryCode].sort((a, b) =>
        a.location.province
          .toLowerCase()
          .localeCompare(b.location.province.toLowerCase())
      ),
    }))
    .sort((a, b) =>
      a.countryCode.toLowerCase().localeCompare(b.countryCode.toLowerCase())
    )
}

export const provinceLongName = ({
  province,
  countryCode,
}: {
  province: string
  countryCode: string
}) => {
  if (countryCode === 'US') {
    return usStateCodeToName(province)
  }

  return province
}

export const provinceLocalName = (countryCode: string): string => {
  switch (countryCode) {
    case 'CA':
      return 'Province'
    default:
      return 'State'
  }
}
