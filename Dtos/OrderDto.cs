namespace PetStoreAPI.Dtos
{
    public class OrderDto
    {
        public int OrderId { get; set; }
        public string UserName { get; set; }
        public string PetName { get; set; }
        public string OrderStatus { get; set; }
    }
} 