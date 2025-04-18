defmodule DurandalWeb.Blog.UploadController do
  use DurandalWeb, :controller
  alias Durandal.Blog

  def get_upload(conn, %{"upload_id" => upload_id}) do
    upload = Blog.get_upload!(upload_id)

    conn
    |> put_resp_content_type(upload.type)
    |> send_file(200, upload.filename)
  end
end
