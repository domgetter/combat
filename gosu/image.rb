
module Gosu

  class Image

    def retro!
      
      glBindTexture(GL_TEXTURE_2D, self.gl_tex_info.tex_name)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
      
      self
    end
    
  end
  
end
