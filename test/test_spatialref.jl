using Test
import GDAL
import ArchGDAL; const AG = ArchGDAL

@testset "Test methods for Spatial Reference Systems" begin
    @testset "PROJ4 String Format" begin
        proj4326 = "+proj=longlat +datum=WGS84 +no_defs "
        proj26912 = "+proj=utm +zone=12 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs "
        AG.importPROJ4(proj4326) do spatialref
            spatialref2 = AG.importPROJ4("+proj=utm +zone=12 +datum=NAD83 +units=m +no_defs ")
            @test AG.toPROJ4(spatialref2) == proj26912
            AG.importPROJ4!(spatialref2, AG.toPROJ4(spatialref))
            @test AG.toPROJ4(spatialref2) == proj4326
        end
    end

    @testset "WKT String Format" begin
        wkt4326 = "GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AUTHORITY[\"EPSG\",\"4326\"]]"
        wkt26912 = "PROJCS[\"NAD83 / UTM zone 12N\",GEOGCS[\"NAD83\",DATUM[\"North_American_Datum_1983\",SPHEROID[\"GRS 1980\",6378137,298.257222101,AUTHORITY[\"EPSG\",\"7019\"]],TOWGS84[0,0,0,0,0,0,0],AUTHORITY[\"EPSG\",\"6269\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AUTHORITY[\"EPSG\",\"4269\"]],PROJECTION[\"Transverse_Mercator\"],PARAMETER[\"latitude_of_origin\",0],PARAMETER[\"central_meridian\",-111],PARAMETER[\"scale_factor\",0.9996],PARAMETER[\"false_easting\",500000],PARAMETER[\"false_northing\",0],UNIT[\"metre\",1,AUTHORITY[\"EPSG\",\"9001\"]],AXIS[\"Easting\",EAST],AXIS[\"Northing\",NORTH],AUTHORITY[\"EPSG\",\"26912\"]]"
        AG.importWKT(wkt4326) do spatialref
            spatialref2 = AG.importWKT(wkt26912)
            @test AG.toWKT(spatialref2) == wkt26912
            AG.importPROJ4!(spatialref2, AG.toPROJ4(spatialref))
            @test AG.toWKT(spatialref2) == wkt4326
        end
    end

    @testset "ESRI Format" begin
        esri4326 = "GEOGCS[\"GCS_WGS_1984\",DATUM[\"D_WGS_1984\",SPHEROID[\"WGS_1984\",6378137,298.257223563]],PRIMEM[\"Greenwich\",0],UNIT[\"Degree\",0.017453292519943295]]"
        test4326 = "GEOGCS[\"GCS_WGS_1984\",DATUM[\"WGS_1984\",SPHEROID[\"WGS_84\",6378137,298.257223563]],PRIMEM[\"Greenwich\",0],UNIT[\"Degree\",0.017453292519943295]]"
        esri26912 = "PROJCS[\"NAD_1983_UTM_Zone_12N\",GEOGCS[\"GCS_North_American_1983\",DATUM[\"D_North_American_1983\",SPHEROID[\"GRS_1980\",6378137,298.257222101]],PRIMEM[\"Greenwich\",0],UNIT[\"Degree\",0.017453292519943295]],PROJECTION[\"Transverse_Mercator\"],PARAMETER[\"latitude_of_origin\",0],PARAMETER[\"central_meridian\",-111],PARAMETER[\"scale_factor\",0.9996],PARAMETER[\"false_easting\",500000],PARAMETER[\"false_northing\",0],UNIT[\"Meter\",1]]"
        test26912 = "PROJCS[\"NAD_1983_UTM_Zone_12N\",GEOGCS[\"GCS_North_American_1983\",DATUM[\"North_American_Datum_1983\",SPHEROID[\"GRS_1980\",6378137,298.257222101]],PRIMEM[\"Greenwich\",0],UNIT[\"Degree\",0.017453292519943295]],PROJECTION[\"Transverse_Mercator\"],PARAMETER[\"latitude_of_origin\",0],PARAMETER[\"central_meridian\",-111],PARAMETER[\"scale_factor\",0.9996],PARAMETER[\"false_easting\",500000],PARAMETER[\"false_northing\",0],UNIT[\"Meter\",1]]"
        AG.importESRI(esri4326) do spatialref
            spatialref2 = AG.importESRI(esri26912)
            @test AG.toWKT(spatialref2) == test26912
            AG.importESRI!(spatialref2, esri4326)
            @test AG.toWKT(spatialref2) == test4326
        end
    end

    @testset "XML Format" begin
        xml4326 = """<gml:GeographicCRS gml:id="ogrcrs1">
          <gml:srsName>GCS_WGS_1984</gml:srsName>
          <gml:usesEllipsoidalCS>
            <gml:EllipsoidalCS gml:id="ogrcrs2">
              <gml:csName>ellipsoidal</gml:csName>
              <gml:csID>
                <gml:name codeSpace="urn:ogc:def:cs:EPSG::">6402</gml:name>
              </gml:csID>
              <gml:usesAxis>
                <gml:CoordinateSystemAxis gml:id="ogrcrs3" gml:uom="urn:ogc:def:uom:EPSG::9102">
                  <gml:name>Geodetic latitude</gml:name>
                  <gml:axisID>
                    <gml:name codeSpace="urn:ogc:def:axis:EPSG::">9901</gml:name>
                  </gml:axisID>
                  <gml:axisAbbrev>Lat</gml:axisAbbrev>
                  <gml:axisDirection>north</gml:axisDirection>
                </gml:CoordinateSystemAxis>
              </gml:usesAxis>
              <gml:usesAxis>
                <gml:CoordinateSystemAxis gml:id="ogrcrs4" gml:uom="urn:ogc:def:uom:EPSG::9102">
                  <gml:name>Geodetic longitude</gml:name>
                  <gml:axisID>
                    <gml:name codeSpace="urn:ogc:def:axis:EPSG::">9902</gml:name>
                  </gml:axisID>
                  <gml:axisAbbrev>Lon</gml:axisAbbrev>
                  <gml:axisDirection>east</gml:axisDirection>
                </gml:CoordinateSystemAxis>
              </gml:usesAxis>
            </gml:EllipsoidalCS>
          </gml:usesEllipsoidalCS>
          <gml:usesGeodeticDatum>
            <gml:GeodeticDatum gml:id="ogrcrs5">
              <gml:datumName>D_WGS_1984</gml:datumName>
              <gml:usesPrimeMeridian>
                <gml:PrimeMeridian gml:id="ogrcrs6">
                  <gml:meridianName>Greenwich</gml:meridianName>
                  <gml:greenwichLongitude>
                    <gml:angle uom="urn:ogc:def:uom:EPSG::9102">0</gml:angle>
                  </gml:greenwichLongitude>
                </gml:PrimeMeridian>
              </gml:usesPrimeMeridian>
              <gml:usesEllipsoid>
                <gml:Ellipsoid gml:id="ogrcrs7">
                  <gml:ellipsoidName>WGS_1984</gml:ellipsoidName>
                  <gml:semiMajorAxis uom="urn:ogc:def:uom:EPSG::9001">6378137</gml:semiMajorAxis>
                  <gml:secondDefiningParameter>
                    <gml:inverseFlattening uom="urn:ogc:def:uom:EPSG::9201">298.257223563</gml:inverseFlattening>
                  </gml:secondDefiningParameter>
                </gml:Ellipsoid>
              </gml:usesEllipsoid>
            </gml:GeodeticDatum>
          </gml:usesGeodeticDatum>
        </gml:GeographicCRS>
        """
        xml26912 = """<gml:ProjectedCRS gml:id="ogrcrs8">
          <gml:srsName>NAD_1983_UTM_Zone_12N</gml:srsName>
          <gml:baseCRS>
            <gml:GeographicCRS gml:id="ogrcrs9">
              <gml:srsName>GCS_North_American_1983</gml:srsName>
              <gml:usesEllipsoidalCS>
                <gml:EllipsoidalCS gml:id="ogrcrs10">
                  <gml:csName>ellipsoidal</gml:csName>
                  <gml:csID>
                    <gml:name codeSpace="urn:ogc:def:cs:EPSG::">6402</gml:name>
                  </gml:csID>
                  <gml:usesAxis>
                    <gml:CoordinateSystemAxis gml:id="ogrcrs11" gml:uom="urn:ogc:def:uom:EPSG::9102">
                      <gml:name>Geodetic latitude</gml:name>
                      <gml:axisID>
                        <gml:name codeSpace="urn:ogc:def:axis:EPSG::">9901</gml:name>
                      </gml:axisID>
                      <gml:axisAbbrev>Lat</gml:axisAbbrev>
                      <gml:axisDirection>north</gml:axisDirection>
                    </gml:CoordinateSystemAxis>
                  </gml:usesAxis>
                  <gml:usesAxis>
                    <gml:CoordinateSystemAxis gml:id="ogrcrs12" gml:uom="urn:ogc:def:uom:EPSG::9102">
                      <gml:name>Geodetic longitude</gml:name>
                      <gml:axisID>
                        <gml:name codeSpace="urn:ogc:def:axis:EPSG::">9902</gml:name>
                      </gml:axisID>
                      <gml:axisAbbrev>Lon</gml:axisAbbrev>
                      <gml:axisDirection>east</gml:axisDirection>
                    </gml:CoordinateSystemAxis>
                  </gml:usesAxis>
                </gml:EllipsoidalCS>
              </gml:usesEllipsoidalCS>
              <gml:usesGeodeticDatum>
                <gml:GeodeticDatum gml:id="ogrcrs13">
                  <gml:datumName>D_North_American_1983</gml:datumName>
                  <gml:usesPrimeMeridian>
                    <gml:PrimeMeridian gml:id="ogrcrs14">
                      <gml:meridianName>Greenwich</gml:meridianName>
                      <gml:greenwichLongitude>
                        <gml:angle uom="urn:ogc:def:uom:EPSG::9102">0</gml:angle>
                      </gml:greenwichLongitude>
                    </gml:PrimeMeridian>
                  </gml:usesPrimeMeridian>
                  <gml:usesEllipsoid>
                    <gml:Ellipsoid gml:id="ogrcrs15">
                      <gml:ellipsoidName>GRS_1980</gml:ellipsoidName>
                      <gml:semiMajorAxis uom="urn:ogc:def:uom:EPSG::9001">6378137</gml:semiMajorAxis>
                      <gml:secondDefiningParameter>
                        <gml:inverseFlattening uom="urn:ogc:def:uom:EPSG::9201">298.257222101</gml:inverseFlattening>
                      </gml:secondDefiningParameter>
                    </gml:Ellipsoid>
                  </gml:usesEllipsoid>
                </gml:GeodeticDatum>
              </gml:usesGeodeticDatum>
            </gml:GeographicCRS>
          </gml:baseCRS>
          <gml:definedByConversion>
            <gml:Conversion gml:id="ogrcrs16">
              <gml:coordinateOperationName>Transverse_Mercator</gml:coordinateOperationName>
              <gml:usesMethod xlink:href="urn:ogc:def:method:EPSG::9807" />
              <gml:usesValue>
                <gml:value uom="urn:ogc:def:uom:EPSG::9102">0</gml:value>
                <gml:valueOfParameter xlink:href="urn:ogc:def:parameter:EPSG::8801" />
              </gml:usesValue>
              <gml:usesValue>
                <gml:value uom="urn:ogc:def:uom:EPSG::9102">-111</gml:value>
                <gml:valueOfParameter xlink:href="urn:ogc:def:parameter:EPSG::8802" />
              </gml:usesValue>
              <gml:usesValue>
                <gml:value uom="urn:ogc:def:uom:EPSG::9001">0.9996</gml:value>
                <gml:valueOfParameter xlink:href="urn:ogc:def:parameter:EPSG::8805" />
              </gml:usesValue>
              <gml:usesValue>
                <gml:value uom="urn:ogc:def:uom:EPSG::9001">500000</gml:value>
                <gml:valueOfParameter xlink:href="urn:ogc:def:parameter:EPSG::8806" />
              </gml:usesValue>
              <gml:usesValue>
                <gml:value uom="urn:ogc:def:uom:EPSG::9001">0</gml:value>
                <gml:valueOfParameter xlink:href="urn:ogc:def:parameter:EPSG::8807" />
              </gml:usesValue>
            </gml:Conversion>
          </gml:definedByConversion>
          <gml:usesCartesianCS>
            <gml:CartesianCS gml:id="ogrcrs17">
              <gml:csName>Cartesian</gml:csName>
              <gml:csID>
                <gml:name codeSpace="urn:ogc:def:cs:EPSG::">4400</gml:name>
              </gml:csID>
              <gml:usesAxis>
                <gml:CoordinateSystemAxis gml:id="ogrcrs18" gml:uom="urn:ogc:def:uom:EPSG::9001">
                  <gml:name>Easting</gml:name>
                  <gml:axisID>
                    <gml:name codeSpace="urn:ogc:def:axis:EPSG::">9906</gml:name>
                  </gml:axisID>
                  <gml:axisAbbrev>E</gml:axisAbbrev>
                  <gml:axisDirection>east</gml:axisDirection>
                </gml:CoordinateSystemAxis>
              </gml:usesAxis>
              <gml:usesAxis>
                <gml:CoordinateSystemAxis gml:id="ogrcrs19" gml:uom="urn:ogc:def:uom:EPSG::9001">
                  <gml:name>Northing</gml:name>
                  <gml:axisID>
                    <gml:name codeSpace="urn:ogc:def:axis:EPSG::">9907</gml:name>
                  </gml:axisID>
                  <gml:axisAbbrev>N</gml:axisAbbrev>
                  <gml:axisDirection>north</gml:axisDirection>
                </gml:CoordinateSystemAxis>
              </gml:usesAxis>
            </gml:CartesianCS>
          </gml:usesCartesianCS>
        </gml:ProjectedCRS>
        """
        AG.importXML(xml4326) do spatialref
            spatialref2 = AG.importXML(xml26912)
            @test startswith(AG.toXML(spatialref2), "<gml:ProjectedCRS")
            AG.importXML!(spatialref2, xml4326)
            @test startswith(AG.toXML(spatialref2), "<gml:GeographicCRS")
        end
    end
end

# untested
# importURL!(spref, projstring)
# importURL(projstring) do spref
# spref = importURL(projstring)
# setattrvalue!(spref, path, value)
# setattrvalue!(spref, path)
# getattrvalue(spref, name, i)
# transform!(coordtransform, xs, ys, zs)
