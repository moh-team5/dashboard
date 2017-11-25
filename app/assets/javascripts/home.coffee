jQuery ->
  # Set map
  map = L.map('mapid').setView([51.505, -0.09], 13)

  L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
    maxZoom: 18,
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
      '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
      'Imagery © <a href="http://mapbox.com">Mapbox</a>',
    id: 'mapbox.streets'
  }).addTo(map)

  # Route
  encoded = "}_ynDf_aoQmbc@_kgAsj^oaw@suCwuJs|FkjHafJycQcsN{xEykXke`@kfFusJysA_vRecPsva@kmN}mOwgEisYuzFytI{hDsn{@cvDmgg@vKolmA{eh@{gp@kbJikCsYcsLa{D}}Rzd@i`VkXo|ZaoOckt@_uCack@q`A_icBdvA{ni@ouBoyk@|Ysld@u|EomSq_Hcx`@m|RazhAku@oue@~cCmdPexIyly@_a@elvA|zIary@hiP{ea@|yCyxXqzMk{BqwaAocc@s~|@it\}ee@_iM{xPfpD}aOmsEmkS_`EeiR{oOcxMcvOwkLqxI{jLcfAy`OgjGalZutQqno@uxSqbGecFul@y}L_kKkta@wcGcxX_pKohOm`_@k}Zc{]gmf@m_f@spk@svPg`QgtFkdQcnAcuf@wnGud`@uoM{~Rec_@__YqnMgt[afFgbNwuLkgSogKaoPc~J_qKy`Qsq`@msM}|RwpOsrSc`RiqQc`N{|Eo_Lm}IszWoxRmbw@_tf@anS}mGu}LkjBkcSgsKsaCc{G_tHihJf`Ai`Llc@q~F{yA{}M}lSsj`@atWsw_@k`S_iQa_fAqz`Aa{Va_YwjLqh_@c~Py{k@|`As~`@tlAueRqgGk{YeoTw}b@u_Rsks@k|Piwb@msFk`[g|KoeVmuTchk@keOci^e~FcmVctUwy}@exI_}m@s`T}jcAFcjVwTatSksHatZq`OweQwxG_pz@e|V{ha@_kUk~p@yqOc|PcwL}qXqxTah]qlOaaW}c]uvUmaQqmXw~U{~UcrT_cP{uVoeLkhPw{BsyEurFkqWqkWciXorPsiN{rDmv[g{X}hPwwTob@_gO{u[gnYafOioGcpl@q|XweTqoVuvEaoMwqIcfJun[slE}eYmgQa{TmpXcgMcfZqyIgl^ytL_uUeyF_gP_xBsm\sbMurc@m{Neq~@keScqvAiQcd`@l~@m}^bxAg`RytEkyIywIwlUa`E}xJdbCmaEu_@i_TnsCubTgfAylXb]k{`@w}J_bP_|QgvQu`Ry_IqvWsm\vV}{G}gG{{EkhIoiC|eAioOvgCw}\`kE{sU`eFeyPksE_`H}kHqmB{LqjHixBcxTm_DapKk{HsuYeuGmkWowGkqVwcMweQ{zDuuJczSohO{kXgyUuaN}pHywH`zAk{Krd@emRiwEekO_sG{eP{`@i~KrcLwvQqsCylE}vA{lGzc@cwFvyBojVwvBu{WumA_mHk_JadGnv@asOdYmwLz`CigHq{GccH~AqtCuwA"
  # polyline = L.Polyline.fromEncoded(encoded)
  polyline = L.polyline(decode(encoded));
  console.log polyline

  # latlngs = [
  #   [38.5, -120.5],
  #   [40.7, -120.95],
  #   [43.252, -126.453]
  # ];
  # polyline = L.polyline(latlngs);
  # console.log polyline

  # L.routing.control
  #   waypoints: [
  #     L.latLng(57.74, 11.94),
  #     L.latLng(57.6792, 11.949)
  #   ],
  #   routeWhileDragging: true
  # .addTo(map)

decode = (encoded) ->
  options = {}
  options.precision = options.precision || 5
  options.factor = options.factor || Math.pow(10, options.precision)
  options.dimension = options.dimension || 2

  flatPoints = decodeDeltas(encoded, options)

  points = []
  i = 0
  len = flatPoints.length
  while i + options.dimension - 1 < len
    point = []
    dim = 0
    while dim < options.dimension
      point.push flatPoints[i++]
      ++dim
    points.push point

  points

decodeDeltas = (encoded, options) -> 
  lastNumbers = []

  numbers = decodeFloats(encoded, options)

  i = 0
  len = numbers.length
  while i < len
    d = 0
    while d < options.dimension
      numbers[i] = Math.round((lastNumbers[d] = numbers[i] + (lastNumbers[d] or 0)) * options.factor) / options.factor
      ++d
      ++i

  numbers

decodeFloats = (encoded, options) ->
  numbers = decodeSignedIntegers(encoded)

  i = 0
  len = numbers.length
  while i < len
    numbers[i] /= options.factor
    ++i

  numbers

decodeSignedIntegers = (encoded) ->
  numbers = decodeUnsignedIntegers(encoded)

  i = 0
  len = numbers.length
  while i < len
    num = numbers[i]
    numbers[i] = if num & 1 then ~(num >> 1) else num >> 1
    ++i

  numbers

decodeUnsignedIntegers = (encoded) ->
  numbers = []

  current = 0
  shift = 0

  i = 0
  len = encoded.length
  while i < len
    b = encoded.charCodeAt(i) - 63
    current |= (b & 0x1f) << shift
    if b < 0x20
      numbers.push current
      current = 0
      shift = 0
    else
      shift += 5
    ++i

  numbers