import countries from '../data/countries.json'
import usStates from '../data/us_states.json'

type MaybeString = string | undefined

type Place = {
  code: string
  name: string
}

const countryCodeToNameMap: Map<string, string> = new Map()

countries.forEach((country: Place) =>
  countryCodeToNameMap.set(country.code, country.name)
)

countryCodeToNameMap.set('US', 'USA')

export const countryCodeToName = (code: string): MaybeString =>
  countryCodeToNameMap.get(code)

const usStateCodeToNameMap: Map<string, string> = new Map()

usStates.forEach((usState: Place) =>
  usStateCodeToNameMap.set(usState.code, usState.name)
)

export const usStateCodeToName = (code: string): MaybeString =>
  usStateCodeToNameMap.get(code)
