# The MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# This implements native php methods used by tcpdf, which have had to be
# reimplemented within Ruby.

module RFPDF

  # http://uk2.php.net/getimagesize
  def getimagesize(filename)
    return nil unless File.exists?(filename)

    out = Hash.new
    type = File::extname(filename)
    if type == '.png'
      open(filename,'rb') do |f|
        # Check signature
        return false if (f.read(8)!=137.chr + 'PNG' + 13.chr + 10.chr + 26.chr + 10.chr)
        # Read header chunk
        f.read(4)
        return false if (f.read(4)!='IHDR')
        out[0] = freadint(f)
        out[1] = freadint(f)
      end

      return out
    end

    return false unless Object.const_defined?(:Magick)

    image = Magick::ImageList.new(filename)
    
    out[0] = image.columns
    out[1] = image.rows
    
    # These are actually meant to return integer values But I couldn't seem to find anything saying what those values are.
    # So for now they return strings. The only place that uses this at the moment is the parsejpeg method, so I've changed that too.
    case image.mime_type
    when "image/gif"
      out[2] = "GIF"
    when "image/jpeg"
      out[2] = "JPEG"
    when "image/png"
      out[2] = "PNG"
    when " 	image/vnd.wap.wbmp"
      out[2] = "WBMP"
    when "image/x-xpixmap"
      out[2] = "XPM"
    end
    out[3] = "height=\"#{image.rows}\" width=\"#{image.columns}\""
    out['mime'] = image.mime_type
    
    # This needs work to cover more situations
    # I can't see how to just list the number of channels with ImageMagick / rmagick
    if image.colorspace.to_s == "CMYKColorspace"
        out['channels'] = 4
    elsif (image.colorspace.to_s == "RGBColorspace") and (image.image_type.to_s != "GrayscaleType")
      out['channels'] = 3
    else
      out['channels'] = 0
    end

    out['bits'] = image.channel_depth
    
    out
  end
  
end
