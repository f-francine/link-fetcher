defmodule LinkFetcherWeb.Pagination do
  use Phoenix.Component

  attr :page_number, :integer, required: true
  attr :total_pages, :integer, required: true
  # only required if paginating links
  attr :page_id, :integer, required: false

  def pagination(assigns) do
    ~H"""
    <div class="flex p-4 justify-center">
      <%= if @page_number > 1 do %>
        <button
          phx-click="paginate"
          phx-value-page={@page_number - 1}
          class="px-3 bg-gray-200 rounded hover:bg-gray-300"
        >
          Previous
        </button>
      <% end %>
      <span class="px-3 py-1 text-gray-700 font-semibold">
        Page {@page_number} of {@total_pages}
      </span>
      <%= if @total_pages > 1 and @page_number < @total_pages do %>
        <button
          phx-click="paginate"
          phx-value-page={@page_number + 1}
          class="px-3 bg-gray-200 rounded hover:bg-gray-300"
        >
          Next
        </button>
      <% end %>
    </div>
    """
  end
end
