module.exports = (id, startdate, enddate, replaces, replacedby, ordinal, cabinet) => {
  const qualifiers = { }

  // Seems like there should be a better way of filtering these...
  if (startdate && startdate != "''")   qualifiers['P580']  = startdate
  if (enddate && enddate != "''")       qualifiers['P582']  = enddate
  if (replaces && replaces != "''")     qualifiers['P1365'] = replaces
  if (replacedby && replacedby != "''") qualifiers['P1366'] = replacedby
  if (ordinal && ordinal != "''")       qualifiers['P1545'] = ordinal
  if (cabinet && cabinet != "''")       qualifiers['P5054'] = cabinet

  if (startdate && enddate && startdate != "''" && enddate != "''" &&
    (startdate > enddate)) throw new Error(`Invalid dates: ${startdate} / ${enddate}`)

  return {
    id,
    claims: {
      P39: {
        value: 'Q2367542',
        qualifiers: qualifiers,
        references: {
          P143: 'Q175482',    // Finnish Wikipedia
          P4656: 'https://fi.wikipedia.org/wiki/Luettelo_ministereist%C3%A4_Suomen_valtiovarainministeri%C3%B6ss%C3%A4'
        },
      }
    }
  }
}
