class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @seller = current_seller

    if params[:buyer_id].present?
      @buyer = Buyer.find(params[:buyer_id])
      @orders = Order.where(buyer_id: @buyer.id, status: 0)
      @total_quantity = 0
      @total_amount = 0
      @orders.each do |order|
        @total_quantity += order.quantity
        @total_amount += order.price*order.quantity
      end

    end

    @products = @seller.products
    @can_create_more_products = false
    @product_limit_free_plan = 3

    if (@seller.plan_type == "Plan Gratis" && @products.count < @product_limit_free_plan)
      @can_create_more_products = true
    elsif @seller.plan_type == "Plan Pagado 1"
      @can_create_more_products = true
    end

  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
    # @origin_route = URI(request.referer).path.to_s[1..6]
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @seller = current_seller
    @product = @seller.products.build(product_params)
    @url = URI(request.referer).path
    @product.save
    respond_to do |format|

      if @product.save
        format.html { redirect_to @url, notice: 'Producto creado desde cliente'}
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end




  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'El producto fue modificado con exito.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json

  # def destroy
  #   @product.destroy
  #   respond_to do |format|
  #     format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  def destroy
   @product.destroy
   respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :no_content }
      format.js   { render :layout => false }
   end
end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:seller_id, :name, :detail, :price, :category)
    end



end
