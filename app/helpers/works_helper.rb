module WorksHelper
  # One work's picture in whatever frame it is hanging in -- a plate on the
  # dashboard, a tile on a project screen, the featured window.
  #
  # A video is muted and loops, so it reads as a moving picture rather than a
  # film with a soundtrack, and `playsinline` is what stops iOS Safari from
  # yanking it fullscreen the moment it starts. Nothing here autoplays: the
  # media controller starts a video when it comes into view and stops it when
  # it leaves, so a project of twenty videos decodes the two you can see.
  #
  # The `#t=0.1` on the end of the address asks the browser for a frame a
  # tenth of a second in. Without it a video that has not been played yet is
  # an empty black rectangle; with it, the frame stands in as its own poster.
  # (A real poster image would need ffmpeg on the server, which there isn't.)
  def work_media_tag(work, source, alt: nil, **options)
    return image_tag(source, options.merge(alt: alt.to_s)) unless work.video?

    # `loading` is an image attribute; `preload` is the video one that does the
    # same job, so callers asking for a lazy picture get a lazy video.
    options.delete(:loading)

    video_tag "#{url_for(source)}#t=0.1",
      options.merge(muted: true, loop: true, playsinline: true, preload: "metadata",
                    "aria-label": alt.presence)
  end
end
