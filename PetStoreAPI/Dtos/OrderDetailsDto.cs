namespace PetStoreAPI.Dtos
{
    public class OrderDetailsDto
    {
        public int OrderId { get; set; }
        public string UserName { get; set; } = default!;
        public string PetName { get; set; } = default!;
        public string OrderStatus { get; set; } = default!;
    }
} 