import { Group } from '../../generated/graphql'

export const initialValues = (chapter: Group) => ({
  name: chapter.name || '',
  slug: chapter.slug || '',
  leader: chapter.leader || '',
  country: chapter.location.countryCode || '',
  state:
    chapter.location.countryCode === 'US'
      ? chapter.location.province || ''
      : '',
  province:
    chapter.location.countryCode !== 'US'
      ? chapter.location.province || ''
      : '',
  donationLink: chapter.donationLink || '',
  postalCode: chapter.location.postalCode || '',
  description: chapter.description || '',
  requestForm: chapter.requestForm || '',
  requestFormResults: chapter.requestFormResults || '',
  donationForm: chapter.donationForm || '',
  donationFormResults: chapter.donationFormResults || '',
  volunteerForm: chapter.volunteerForm || '',
  volunteerFormResults: chapter.volunteerFormResults || '',
})
